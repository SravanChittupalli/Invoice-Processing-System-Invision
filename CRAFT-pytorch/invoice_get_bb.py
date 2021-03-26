# -*- coding: utf-8 -*-

import argparse
import os
import time
from collections import OrderedDict

import cv2
import numpy as np

# PyTorch Imports
import torch
import torch.backends.cudnn as cudnn
from torch.autograd import Variable

# Tesseract imports
import pytesseract
from pytesseract import Output

# Craft imports
import craft_utils
import file_utils
import imgproc
from craft import CRAFT

#tesseract config
custom_config = r'--psm 11'

def copyStateDict(state_dict):
    if list(state_dict.keys())[0].startswith("module"):
        start_idx = 1
    else:
        start_idx = 0
    new_state_dict = OrderedDict()
    for k, v in state_dict.items():
        name = ".".join(k.split(".")[start_idx:])
        new_state_dict[name] = v
    return new_state_dict

def str2bool(v):
    return v.lower() in ("yes", "y", "true", "t", "1")

parser = argparse.ArgumentParser(description='CRAFT Text Detection')
parser.add_argument('--trained_model', default='weights/craft_mlt_25k.pth', type=str, help='pretrained model')
parser.add_argument('--text_threshold', default=0.7, type=float, help='text confidence threshold')
parser.add_argument('--low_text', default=0.4, type=float, help='text low-bound score')
parser.add_argument('--link_threshold', default=0.4, type=float, help='link confidence threshold')
parser.add_argument('--cuda', default=True, type=str2bool, help='Use cuda for inference')
parser.add_argument('--canvas_size', default=1280, type=int, help='image size for inference')
parser.add_argument('--mag_ratio', default=1.5, type=float, help='image magnification ratio')
parser.add_argument('--poly', default=False, action='store_true', help='enable polygon type')
parser.add_argument('--show_time', default=False, action='store_true', help='show processing time')

args = parser.parse_args()

# Store results here
result_folder = './result/'
image_path = '/home/sravanchittupalli/konnoha/clones/Invoice-Processing-System/tesseract/assets/input/X00016469619.jpg'
if not os.path.isdir(result_folder):
    os.mkdir(result_folder)


def test_net(net, image, text_threshold, link_threshold, low_text, cuda, poly, refine_net=None):
    t0 = time.time()

    # resize
    img_resized, target_ratio, size_heatmap = imgproc.resize_aspect_ratio(image, args.canvas_size, interpolation=cv2.INTER_LINEAR, mag_ratio=args.mag_ratio)
    ratio_h = ratio_w = 1 / target_ratio

    # preprocessing
    x = imgproc.normalizeMeanVariance(img_resized)
    x = torch.from_numpy(x).permute(2, 0, 1)    # [h, w, c] to [c, h, w]
    x = Variable(x.unsqueeze(0))                # [c, h, w] to [b, c, h, w]
    if cuda:
        x = x.cuda()

    # forward pass
    with torch.no_grad():
        y, feature = net(x)

    # make score and link map
    score_text = y[0,:,:,0].cpu().data.numpy()
    score_link = y[0,:,:,1].cpu().data.numpy()

    # refine link
    if refine_net is not None:
        with torch.no_grad():
            y_refiner = refine_net(y, feature)
        score_link = y_refiner[0,:,:,0].cpu().data.numpy()

    t0 = time.time() - t0
    t1 = time.time()

    # Post-processing
    boxes, polys = craft_utils.getDetBoxes(score_text, score_link, text_threshold, link_threshold, low_text, poly)

    # coordinate adjustment
    boxes = craft_utils.adjustResultCoordinates(boxes, ratio_w, ratio_h)
    polys = craft_utils.adjustResultCoordinates(polys, ratio_w, ratio_h)
    for k in range(len(polys)):
        if polys[k] is None: polys[k] = boxes[k]

    t1 = time.time() - t1

    # render results (optional)
    render_img = score_text.copy()
    render_img = np.hstack((render_img, score_link))
    ret_score_text = imgproc.cvt2HeatmapImg(render_img)

    if args.show_time : print("\ninfer/postproc time : {:.3f}/{:.3f}".format(t0, t1))

    return boxes, polys, ret_score_text

def main(image):
    # load net
    net = CRAFT()     # initialize
    refine_net = None

    print('Loading weights from checkpoint (' + args.trained_model + ')')
    if args.cuda:
        net.load_state_dict(copyStateDict(torch.load(args.trained_model)))
    else:
        net.load_state_dict(copyStateDict(torch.load(args.trained_model, map_location='cpu')))

    if args.cuda:
        net = net.cuda()
        net = torch.nn.DataParallel(net)
        cudnn.benchmark = False

    net.eval()

    t = time.time()

    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    bboxes, polys, score_text = test_net(net, image, args.text_threshold, args.link_threshold, args.low_text, args.cuda, args.poly, refine_net)

    # print(bboxes, polys)
    print(image.shape)
    ###############################
    lines = []
    
    min_line = 100000
    max_line = 0
    for i in range (len(polys)):
        # x1, y1, x2, y2....
        poly = np.array(polys[i]).astype(np.int32).reshape((-1))
        y_coord = [poly[1], poly[3], poly[5], poly[7]]
        if min_line == 100000 and max_line == 0:
            min_line = min(y_coord)
            max_line = max(y_coord)

        if i == len(polys)-1:
            lines.append([min_line, max_line])
            break
        poly_next = np.array(polys[i+1]).astype(np.int32).reshape((-1))
        y_coord_next = [poly_next[1], poly_next[3], poly_next[5], poly_next[7]]

        if abs(min(y_coord) - min(y_coord_next)) < 10 and abs(max(y_coord) - max(y_coord_next)) < 10:
            min_line = min(min(y_coord), min(y_coord_next))
            max_line = max(max(y_coord), max(y_coord_next))
            
        else:
            lines.append([min_line, max_line])
            min_line = 100000
            max_line = 0
    print(len(lines))

    image_line = image.copy()
    for line in lines:
        cv2.rectangle(image_line, (0, line[0]), (image.shape[1], line[1]), (90,239,155), 3)
        roi = image[line[0]-3:line[1]+3, 0:image.shape[1], :]
        img = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
        extracted_text = pytesseract.image_to_string(img, config=custom_config)
        print(extracted_text)
        cv2.imshow('line_img', img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    cv2.imshow('line_img', image_line)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

        
    ################################
    # save score text
    filename, file_ext = os.path.splitext(os.path.basename(image_path))
    mask_file = result_folder + "/res_" + filename + '_mask.jpg'
    cv2.imwrite(mask_file, score_text)

    file_utils.saveResult(image_path, image[:,:,::-1], polys, dirname=result_folder)

    print("elapsed time : {}s".format(time.time() - t))


if __name__ == '__main__':
    image = cv2.imread('/home/sravanchittupalli/konnoha/clones/Invoice-Processing-System/tesseract/assets/input/X51005301661.jpg')
    main(image)

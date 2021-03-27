# -*- coding: utf-8 -*-

import argparse
import os
import time
from collections import OrderedDict

import cv2
import numpy as np

import re

# PyTorch Imports
import torch
import torch.backends.cudnn as cudnn
from torch.autograd import Variable

# Tesseract imports
import pytesseract
from pytesseract import Output

# Craft imports
from CRAFT_pytorch import craft_utils
from CRAFT_pytorch import file_utils
from CRAFT_pytorch import imgproc
from CRAFT_pytorch.craft import CRAFT

#tesseract config
custom_config = r'--psm 11'

receipt_ocr = {}

def get_date(extracted_text):
# regex for date. The pattern in the receipt is in 30.07.2007 in DD:MM:YYYY
    date_pattern = r'(0[1-9]|[12][0-9]|3[01]|0[1-9]|1[012])[-./](0[1-9]|[12][0-9]|3[01]|0[1-9]|1[012])[-./](20[012][0-9]|[0-3][0-9])'
    pattern = re.compile(date_pattern)
    matches = pattern.finditer(extracted_text)
    date = None
    for match in matches:
        date = extracted_text[match.span()[0]:match.span()[1]]
    receipt_ocr['date'] = date
    print(receipt_ocr)

def get_time(extracted_text):
# regex for time. The pattern in the receipt is in 8:47:20 
    time_pattern = r'([0-9]|0[0-9]|[1][0-9]|2[0-4])[:]([0-5][0-9])[:]([0-5][0-9])*'
    pattern = re.compile(time_pattern)
    matches = pattern.finditer(extracted_text)
    time = None
    for match in matches:
        time = extracted_text[match.span()[0]:match.span()[1]]
    receipt_ocr['time'] = time
    print(receipt_ocr)

def get_total(extracted_text):
    total_pattern = r'[tTiI][oOaA][tTlLiL][oOaA0cC]'
    # total_pattern = r'Total'
    splits = extracted_text.split('\n')
    lines_with_total = []
    for line in splits:
        if re.search(total_pattern, line):
            lines_with_total.append(line)
    
    amount = []
    amount_pattern = r'[0-9]+\.[0-9]+'
    pattern = re.compile(amount_pattern)
    for line in lines_with_total:
        matches = pattern.finditer(line)
        for match in matches:
            amount.append(float(line[match.span()[0]:match.span()[1]]))
    try:
        receipt_ocr['total'] = str(max(amount))
    except:
        receipt_ocr['total'] = None
    print(receipt_ocr)

def get_company_name(extracted_text):
    splits = extracted_text.splitlines()
    i = 0
    pattern = r'([0-9]+|[-./]+|\\)'

    for split in splits:
        if split==' ':
            # print(split)
            i+=1
            continue
        if re.search(pattern, split):
            # print(split)
            i+=1
        else:
            break
    try:
        restaurant_name = splits[i] + '\n' + splits[i+2]
        receipt_ocr['Comapny Name'] = restaurant_name
    except:
        receipt_ocr['Comapny Name'] = None
    print(receipt_ocr)

def get_GST_number(extracted_text):
    pattern = r'(GST)'
    splits = extracted_text.split('\n')
    lines_with_GST = []
    for line in splits:
        if re.search(pattern, line, re.IGNORECASE):
            lines_with_GST.append(line)

    gst_num = ''
    gst_num_pattern = r'[0-9]{3,15}\s*[0-9]*\s*[0-9]*'
    pattern = re.compile(gst_num_pattern)
    for line in lines_with_GST:
        matches = pattern.finditer(line)
        for match in matches:
            gst_num_curr = line[match.span()[0]:match.span()[1]]
            if len(gst_num_curr) > len(gst_num):
                gst_num = gst_num_curr

    receipt_ocr['GST Number'] = gst_num
    print(receipt_ocr)

def get_email(extracted_text):
    pattern = (r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+')
    pattern = re.compile(pattern)
    matches = pattern.finditer(extracted_text)
    email = None
    for match in matches:
        email = extracted_text[match.span()[0]:match.span()[1]]
    receipt_ocr['email'] = email
    print(receipt_ocr)


def get_phone_number(extracted_text):
    pattern = (r'(Telephone|tel|Ph|Phone|Mob|Mobile|dial)')
    splits = extracted_text.split('\n')
    lines_with_phone_num = []
    for line in splits:
        if re.search(pattern, line, re.IGNORECASE):
            lines_with_phone_num.append(line)

    phone_num = []

    phone_num_pattern = r'[+-]*[0-9]+[-]*[0-9]*\s*[+-]*[0-9]*[-.)(]*[0-9]*\s*'
    pattern = re.compile(phone_num_pattern)
    for line in lines_with_phone_num:
        matches = pattern.finditer(line)
        for match in matches:
            phone_num.append(line[match.span()[0]:match.span()[1]])

    receipt_ocr['Phone Number'] = phone_num
    print(receipt_ocr)

def get_invoice_number(extracted_text):
    pattern = (r'(invoice|bill|inv|inc|doc|document|order|ord|receipt|billing|token|trn|transaction|trx|tally|statement)')
    splits = extracted_text.split('\n')
    lines_with_invoice_num = []
    for line in splits:
        if re.search(pattern, line, re.IGNORECASE):
            lines_with_invoice_num.append(line)

    invoice_num = []
    final_invoice = None
    invoice_num_pattern = r'[a-zA-Z]*[0-9]+[/:-]*[0-9]*[/:-]*[0-9]*'
    pattern = re.compile(invoice_num_pattern)
    for line in lines_with_invoice_num:
        matches = pattern.finditer(line)
        for match in matches:
            invoice_num.append(line[match.span()[0]:match.span()[1]])

    for invoice in invoice_num:
        if '/' not in invoice and ':' not in invoice and ' ' not in invoice:
            final_invoice = invoice

    receipt_ocr['Invoice Number'] = final_invoice
    print(receipt_ocr)


def str2bool(v):
    return v.lower() in ("yes", "y", "true", "t", "1")

parser = argparse.ArgumentParser(description='CRAFT Text Detection')
parser.add_argument('--trained_model', default='CRAFT_pytorch/weights/craft_mlt_25k.pth', type=str, help='pretrained model')
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
# image_path = '/home/sravanchittupalli/konnoha/clones/Invoice-Processing-System/tesseract/assets/input/X00016469619.jpg'
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

def get_observations(image, net):
    refine_net = None
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

    text_in_img = ''
    image_line = image.copy()
    for line in lines:
        cv2.rectangle(image_line, (0, line[0]), (image.shape[1], line[1]), (90,239,155), 3)
        roi = image[line[0]-3:line[1]+3, 0:image.shape[1], :]
        img = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
        extracted_text = pytesseract.image_to_string(img, config=custom_config)
        # print(extracted_text)
        line = ''
        for extract in extracted_text.split('\n'):
            line = line+extract+' '
        text_in_img = text_in_img+line+'\n'
        # cv2.imshow('line_img', img)
        # cv2.waitKey(0)
        # cv2.destroyAllWindows()

    print(text_in_img)

    get_date(text_in_img)
    get_time(text_in_img)
    get_total(text_in_img)
    get_company_name(text_in_img)
    get_GST_number(text_in_img)
    get_email(text_in_img)
    get_phone_number(text_in_img)
    get_invoice_number(text_in_img)
    cv2.imshow('line_img', image_line)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

        
    ################################
    # save score text
    # filename, file_ext = os.path.splitext(os.path.basename(image_path))
    # mask_file = result_folder + "/res_" + filename + '_mask.jpg'
    # cv2.imwrite(mask_file, score_text)

    # file_utils.saveResult(image_path, image[:,:,::-1], polys, dirname=result_folder)

    print("elapsed time : {}s".format(time.time() - t))
    return receipt_ocr


if __name__ == '__main__':
    image_path = '/home/sravanchittupalli/konnoha/clones/Invoice-Processing-System/CRAFT-pytorch/assets/X51005441402.jpg'
    image = cv2.imread(image_path)
    get_observations(image)
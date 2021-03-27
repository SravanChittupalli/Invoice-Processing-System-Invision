from flask import Flask, render_template , request , jsonify
from PIL import Image
import os , io , sys
import numpy as np 
import cv2
from collections import OrderedDict

import torch
import torch.backends.cudnn as cudnn

from CRAFT_pytorch.invoice_get_bb import get_observations
from CRAFT_pytorch.craft import CRAFT

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return "Default Route"


@app.route('/getObs' , methods=['POST'])
def get_obs():
    file = request.files['image'].read() ## byte file
    npimg = np.fromstring(file, np.uint8)
    img = cv2.imdecode(npimg,cv2.IMREAD_COLOR)
	######### Do preprocessing here ################
    dict_ocr_obs = get_observations(img, net)
    print(dict_ocr_obs)

    # Making the response message
    response = {
        "output":
            {
                "date": dict_ocr_obs["date"],
                "time": dict_ocr_obs["time"],
                "total": dict_ocr_obs["total"],
                "Comapny Name": dict_ocr_obs["Comapny Name"],
                "GST Number": dict_ocr_obs["GST Number"],
                "email": dict_ocr_obs["email"],
                "Phone Number": dict_ocr_obs["Phone Number"],
                "Invoice Number": dict_ocr_obs["Invoice Number"]
            }
    }
    return jsonify(response) # send to app

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


if __name__ == '__main__':
    trained_model = 'CRAFT_pytorch/weights/craft_mlt_25k.pth'
    cuda = True
    # load net
    net = CRAFT()     # initialize

    print('Loading weights from checkpoint (' + trained_model + ')')
    if cuda:
        net.load_state_dict(copyStateDict(torch.load(trained_model)))
    else:
        net.load_state_dict(copyStateDict(torch.load(trained_model, map_location='cpu')))

    if cuda:
        net = net.cuda()
        net = torch.nn.DataParallel(net)
        cudnn.benchmark = False

    net.eval()

    app.run()
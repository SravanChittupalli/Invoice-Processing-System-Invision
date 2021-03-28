from collections import OrderedDict

import cv2
import numpy as np
import torch
import torch.backends.cudnn as cudnn
from flask import Flask, jsonify, request

from CRAFT_pytorch.craft import CRAFT
from CRAFT_pytorch.invoice_get_bb import get_observations
from CRAFT_pytorch.skew_correction import correct_image

from firebase import firebase  

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return "Default Route"


@app.route('/getObs' , methods=['POST'])
def get_obs():
    file = request.files['image'].read() ## byte file
    npimg = np.fromstring(file, np.uint8)
    img = cv2.imdecode(npimg,cv2.IMREAD_COLOR)
    print("[DEBUG] Received image")
	######### Do preprocessing here ################
    # img = correct_image(img)
    # print("done corrected image")
    print("[DEBUG] Perform OCR")
    dict_ocr_obs = get_observations(img, net)
    print("[DEBUG] Done with OCR")

    data = {
                "date": dict_ocr_obs["date"],
                "time": dict_ocr_obs["time"],
                "total": dict_ocr_obs["total"],
                "CompanyName": dict_ocr_obs["CompanyName"],
                "GSTNumber": dict_ocr_obs["GSTNumber"],
                "email": dict_ocr_obs["email"],
                "PhoneNumber": dict_ocr_obs["PhoneNumber"],
                "InvoiceNumber": dict_ocr_obs["InvoiceNumber"],
                "currency": dict_ocr_obs["currency"]
            }
    # Storing results in firebase
    print("[DEBUG] Storing results in firebase")
    firebase.post('/user1/',data)
    print("[DEBUG] Successfully uploaded results")

    # Making the response message
    response = {
        "output": data
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
    firebase = firebase.FirebaseApplication('https://invoicexvision-invision-default-rtdb.firebaseio.com/', None)  

    trained_model = 'CRAFT_pytorch/weights/craft_mlt_25k.pth'
    
    cuda = True
    # load net
    net = CRAFT()

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

    app.run(port = 8080)
from flask import Flask, render_template , request , jsonify
from PIL import Image
import os , io , sys
import numpy as np 
import cv2

from CRAFT_pytorch.invoice_get_bb import get_observations

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return "Default Route"


@app.route('/getObs' , methods=['POST'])
def get_obs():
	# print(request.files , file=sys.stderr)
    # return "hello"
    file = request.files['image'].read() ## byte file
    npimg = np.fromstring(file, np.uint8)
    img = cv2.imdecode(npimg,cv2.IMREAD_COLOR)
	######### Do preprocessing here ################
    dict_ocr_obs = get_observations(img)
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
	################################################
    # img = Image.fromarray(img.astype("uint8"))
    # rawBytes = io.BytesIO()
    # img.save(rawBytes, "JPEG")
    # rawBytes.seek(0)
    # img_base64 = base64.b64encode(rawBytes.read())
    # return jsonify({'status':str(img_base64)})
    # return "done"

if __name__ == '__main__':
    app.run()
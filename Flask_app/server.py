from flask import Flask
from flask import jsonify
from flask import request
from PIL import Image
import numpy as np

app = Flask(__name__)

@app.route('/go', methods=['POST', 'GET'])
def hello_world():
	print("Hello called!")
	return jsonify({'message' : 'Hello, World!'})

@app.route('/getObs', methods=["POST"])
def predict():
    # stuff not relevant to question, left out for conciseness #
    file = request.files['image']
    im1 = file.save("geeks.jpg")

    return jsonify({"output":
            {
                "date": "DAte",
                "time": "TIme",
                "total": "Total",
                "CompanyName": "Company",
                "GSTNumber": "GST",
                "email": "Email",
                "PhoneNumber": "PhoneNumber",
                "InvoiceNumber": "InvoiceNumber",
                "currency" : "currency"
            }})


if __name__ == "__main__":
    app.run(debug=True, port = 8080)    
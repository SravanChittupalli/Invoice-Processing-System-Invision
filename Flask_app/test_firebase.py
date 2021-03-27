from firebase import firebase  
firebase = firebase.FirebaseApplication('https://invoic-processing-system-default-rtdb.firebaseio.com/', None)  
data =  {
                "date": "12/24/21",
                "time": "15:34",
                "total": "234.0",
                "Comapny Name": "HelloGoogle",
                "GST Number": "AST2351129ow",
                "email": "hellogoogle@gmail.com",
                "Phone Number": ["2234902093", "35527", "238764823"],
                "Invoice Number": "W1234FaD"
            }
result = firebase.post('/user1/',data)  
print(result)
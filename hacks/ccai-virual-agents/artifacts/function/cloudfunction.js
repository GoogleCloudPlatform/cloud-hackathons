import datetime
import os
import random
import string
from firebase_admin import db, initialize_app
from firebase_functions import https_fn
import flask
from flask import request
from google.cloud import firestore

initialize_app()
app = flask.Flask(__name__)

@app.post("/vacation_days")
def vacation_days():
  vacation_days = "".join(
     Math.floor(Math.random() * (30 - 1 + 1)) + 1  // Math.random() * (max - min + 1)) + min
  )
  return flask.jsonify({"vacation days left": vacation_days})


@https_fn.on_request()
def main(req: https_fn.Request) -> https_fn.Response:
  with app.request_context(req.environ):
    return app.full_dispatch_request()


from flask import Flask, redirect, render_template, url_for
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import psycopg2

datbaseName = 'postgres'
Password = "Password"

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{datbaseName}:{Password}@localhost/postgres'
db = SQLAlchemy(app)


'''
class audit(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    operation = db.Column(db.String(15))
    username = db.Column(db.String(30))
    timeLog = db.Column(db.DateTime, default=datetime.utcnow)
    previous = db.Column(db.JSON)
    updated = db.Column(db.JSON)
'''
class road_network(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text)
    location = db.Column(db.Text)
    desciption = db.Column(db.Text)
    lat = db.Column(db.Float)
    lon = db.Column(db.Float)



@app.route('/')
def index():
    info = road_network.query.all()
    return render_template('layout.html', info=info)

@app.route("/audit")
def get_audit():
    conn = psycopg2.connect(
        database=f"{datbaseName}", user='postgres', password=f'{Password}', host='localhost', port= '5432'
    )
    cursor = conn.cursor()
    cursor.execute("""SELECT * FROM audit""")
    # gives a tuple we can index it in audit.html
    data = cursor.fetchall()
    #print("Connection established to: ",data)
    conn.close()
    return render_template('audit.html', data= data)

@app.route("/update")
def get_update():
    return render_template('update.html')

@app.route("/delete/<int:id>")
def delete(id):
    deleteRecord = road_network.query.filter_by(id=id).first()
    db.session.delete(deleteRecord)
    db.session.commit()
    return redirect(url_for('index'))


if __name__ == "__main__":
    app.run(debug=True)
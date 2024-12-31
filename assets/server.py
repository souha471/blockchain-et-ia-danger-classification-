from flask import Flask, request, jsonify
from flask_cors import CORS
import bcrypt  # Pour hacher les mots de passe
import numpy as np
import tensorflow as tf
import joblib
import mysql.connector

app = Flask(__name__)
CORS(app)  # Autoriser les requêtes CORS

# Connexion à la base de données MySQL
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="pollution"
)

# Charger le modèle TFLite
interpreter = tf.lite.Interpreter(model_path="model_danger_classification.tflite")
interpreter.allocate_tensors()

# Charger le scaler
scaler = joblib.load('scaler.pkl')

# Routes pour l'authentification
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not all(key in data for key in ['username', 'password']):
        return jsonify({'error': 'Données manquantes'}), 400

    username = data['username']
    password = data['password']

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    cursor = db.cursor()
    try:
        cursor.execute("INSERT INTO users (username, password) VALUES (%s, %s)", (username, hashed_password))
        db.commit()
        return jsonify({'message': 'Utilisateur enregistré avec succès !'})
    except mysql.connector.errors.IntegrityError:
        return jsonify({'error': 'Nom d’utilisateur déjà pris'}), 409

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not all(key in data for key in ['username', 'password']):
        return jsonify({'error': 'Données manquantes'}), 400

    username = data['username']
    password = data['password']

    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
    user = cursor.fetchone()

    if user and bcrypt.checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
        return jsonify({'message': 'Connexion réussie !', 'username': user['username']})
    else:
        return jsonify({'error': 'Nom d’utilisateur ou mot de passe incorrect'}), 401
@app.route('/get_normal_data', methods=['GET'])
def get_normal_data():
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT id, Quantite AS value FROM sans_danger")  # Adaptez selon votre table
    data = cursor.fetchall()
    return jsonify(data)

# Route pour la prédiction
@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    if not all(key in data for key in ['Quantité (L)', 'Zone Affectée (km²)', 'Durée (heures)']):
        return jsonify({'error': 'Données manquantes'}), 400

    quantity = data['Quantité (L)']
    zone = data['Zone Affectée (km²)']
    duration = data['Durée (heures)']

    input_data = np.array([[quantity, zone, duration]], dtype=np.float32)
    input_scaled = scaler.transform(input_data)

    interpreter.set_tensor(interpreter.get_input_details()[0]['index'], input_scaled)
    interpreter.invoke()
    output_data = interpreter.get_tensor(interpreter.get_output_details()[0]['index'])

    result = "Oui" if output_data[0] > 0.5 else "Non"
    probability = output_data[0].item()

    # N'insérer les données dans la base de données que si la prédiction est "Non"
    if result == "Non":
        cursor = db.cursor()
        sql = "INSERT INTO sans_danger (Quantite, ZoneAffectee, Duree) VALUES ( %s, %s, %s)"
        values = (quantity, zone, duration)
        cursor.execute(sql, values)
        db.commit()

    return jsonify({'result': result, 'probability': float(probability)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)  # Écoutez sur toutes les interfaces

from flask import Flask, request, jsonify
import pymysql

application = app = Flask(__name__)


@app.route('/api/', methods=['GET'])
def getValues():
    try:
        return jsonify(Settings().serialize())
    except:
        return not_found('Settings does not exist')


@app.route('/api/', methods=['POST'])
def insertValue():
    if not request.is_json or ('engine' and 'light' and 'fan' not in request.get_json()):
        return bad_request('Missing required data.')
    data = request.get_json()
    Settings().set_details(data.get("engine"), data.get("light"), data.get("fan"))
    return jsonify({'settings': Settings.serialize}), 200


def not_found(message):
    response = jsonify({'error': message})
    response.status_code = 404
    return response


def bad_request(message):
    response = jsonify({'error': message})
    response.status_code = 400
    return response


if __name__ == "__main__":
    app.run(debug=True)


class Settings:

    def connectionDB(self):
        host = 'rdstolambda.c9iuunds4j0l.us-east-1.rds.amazonaws.com'
        port = 3306
        user = 'admin'
        passwd = '*******'
        database_name = 'api_Transactions'
        conn = pymysql.connect(
            host=host,
            port=port,
            user=user,
            password=passwd,
            db=database_name, )
        return conn

    def get_details(self):
        conn = self.connectionDB()
        cur = conn.cursor()
        cur.execute('SELECT * FROM Transaction order by id DESC LIMIT 0,1')
        details = cur.fetchall()
        return details

    def set_details(self, engine, light, fan):
        conn = self.connectionDB()
        cur = conn.cursor()
        cur.execute("INSERT INTO Transaction (engine,light,fan) VALUES (%s,%s,%s)", (engine, light, fan))
        conn.commit()

    def serialize(self):
        data = self.get_details()[0]
        return {
            'engine': data[1],
            'light': data[2],
            'fan': data[3],
        }

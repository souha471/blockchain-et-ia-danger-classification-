import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // Client HTTP pour les appels JSON-RPC

class EthereumService {
  final String _rpcUrl = "http://127.0.0.1:7545"; // Adresse Ganache
  final String _privateKey =
      "0x538ea8739f5230b104c579fee9bf91bb133e6058927bca5b29057eff832fee38";
  final String _contractAddress = "0x5dEc970Bb06b8541dd4cb6e021Bd45cb4Ef6602A";

  late Web3Client _client;
  late Credentials _credentials;
  late DeployedContract _contract;

  EthereumService() {
    _client = Web3Client(_rpcUrl, Client());
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _credentials = EthPrivateKey.fromHex(_privateKey);

      // ABI JSON du nouveau contrat
      String abi = '''[
        {
          "inputs": [
            { "internalType": "uint256", "name": "_id", "type": "uint256" },
            { "internalType": "uint256", "name": "_quantite", "type": "uint256" },
            { "internalType": "uint256", "name": "_zoneAffectee", "type": "uint256" },
            { "internalType": "uint256", "name": "_duree", "type": "uint256" }
          ],
          "name": "recordIncident",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "getIncidents",
          "outputs": [
            {
              "components": [
                { "internalType": "uint256", "name": "id", "type": "uint256" },
                { "internalType": "uint256", "name": "quantite", "type": "uint256" },
                { "internalType": "uint256", "name": "zoneAffectee", "type": "uint256" },
                { "internalType": "uint256", "name": "duree", "type": "uint256" }
              ],
              "internalType": "struct IncidentContract.Incident[]",
              "name": "",
              "type": "tuple[]"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        }
      ]''';

      _contract = DeployedContract(
        ContractAbi.fromJson(abi, "IncidentContract"),
        EthereumAddress.fromHex(_contractAddress),
      );
    } catch (e) {
      print("Erreur lors de l'initialisation : $e");
    }
  }

  Future<void> recordIncident(
    int id,
    int quantite,
    int zoneAffectee,
    int duree,
  ) async {
    try {
      final function = _contract.function("recordIncident");
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [
            BigInt.from(id),
            BigInt.from(quantite),
            BigInt.from(zoneAffectee),
            BigInt.from(duree),
          ],
        ),
        chainId: 1337,
      );
    } catch (e) {
      print("Erreur lors de l'enregistrement de l'incident : $e");
    }
  }

  Future<List<Map<String, dynamic>>> getIncidents() async {
    try {
      final function = _contract.function("getIncidents");
      final results = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );

      return (results[0] as List).map((incident) {
        final List<dynamic> incidentData = incident as List<dynamic>;
        return {
          "id": (incidentData[0] as BigInt).toInt(),
          "quantite": (incidentData[1] as BigInt).toInt(),
          "zoneAffectee": (incidentData[2] as BigInt).toInt(),
          "duree": (incidentData[3] as BigInt).toInt(),
        };
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des incidents : $e");
      return [];
    }
  }

  void dispose() {
    _client.dispose();
  }
}

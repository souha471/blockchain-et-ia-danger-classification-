// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract IncidentContract {
    struct Incident {
        uint id; // Identifiant unique
        uint quantite; // Quantité
        uint zoneAffectee; // Zone affectée
        uint duree; // Durée
    }

    Incident[] public incidents; // Tableau pour stocker les incidents

    event IncidentRecorded(uint id, uint quantite, uint zoneAffectee, uint duree);

    // Fonction pour enregistrer un incident
    function recordIncident(
        uint _id,
        uint _quantite,
        uint _zoneAffectee,
        uint _duree
    ) public {
        incidents.push(Incident(_id, _quantite, _zoneAffectee, _duree));
        emit IncidentRecorded(_id, _quantite, _zoneAffectee, _duree);
    }

    // Fonction pour récupérer tous les incidents
    function getIncidents() public view returns (Incident[] memory) {
        return incidents;
    }

    // Fonction pour récupérer un incident par ID
    function getIncidentById(uint _id) public view returns (Incident memory) {
        for (uint i = 0; i < incidents.length; i++) {
            if (incidents[i].id == _id) {
                return incidents[i];
            }
        }
        revert("Incident not found");
    }
}

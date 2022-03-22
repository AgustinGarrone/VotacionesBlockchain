pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

contract sistema {

    address persona;
    constructor () public{
        persona=msg.sender;
    }

 
    struct candidato {
        string nombre;
        uint votos;
    }
    
    uint numeroCandidatos=0;
    candidato [] public listaCandidatos;

    //mapping para ver si la persona voto
    mapping (address=>bool) votante;
    mapping (address=>bool) candidatoMapping;
    mapping (uint=> string) ganador;

    //eventos
    event candidaturaPresentada(string);
    event votoPresentado(string);
    event ganadorDeclarado(string);


    
    //verifica si ya esta presentado el candidato o si la wallet ya registró a alguien
    modifier boolcand(string memory _name, address _dir) {
        bool presentado=false;
        for (uint i=0;i<listaCandidatos.length;i++) { 
            if((keccak256(abi.encodePacked(_name))==keccak256(abi.encodePacked(listaCandidatos[i].nombre))) ||(candidatoMapping[_dir]==true)  ) {
                presentado=true;
            }
        } 
        candidatoMapping[_dir]=true;
        require(presentado==false,"ya esta presentado ese nombre o wallet ya registrada");
        _;
    }

    function presentarCandidatura(string memory _nombre) public boolcand(_nombre,msg.sender) {
        listaCandidatos.push(candidato(_nombre,0));
        emit candidaturaPresentada("Candidatura presentada correctamente");
        numeroCandidatos++;
    }


    modifier boolvoto(string memory _nombre) {
        bool candidatoEncontrado=false;
        for (uint i=0;i<listaCandidatos.length;i++) {
            if (keccak256(abi.encodePacked(_nombre))==keccak256(abi.encodePacked(listaCandidatos[i].nombre))) {
                candidatoEncontrado=true;
            }
        }
        require(candidatoEncontrado==true,"el candidato no se encuentra presentado");
        _;
    }

    //emite voto si aun no votaste y si encuentra al candidato
    function emitirVoto (string memory _nombre) public boolvoto(_nombre){
        require (votante[msg.sender]==false,"ERROR,ya emitiste un voto antes");
        for (uint i=0;i<listaCandidatos.length;i++) {
            if (keccak256(abi.encodePacked(_nombre))==keccak256(abi.encodePacked(listaCandidatos[i].nombre))) {
                votante[msg.sender]=true;
                listaCandidatos[i].votos=listaCandidatos[i].votos+1;
                emit votoPresentado("voto registrado correctamente");
            }
        }
    }

    function verVotos() public view returns (candidato [] memory){
        return listaCandidatos;
    }

    function declararGanador () public returns (string memory) {
        uint votosGanador=0;
        for (uint i=0;i<listaCandidatos.length;i++) {
            if (listaCandidatos[i].votos>votosGanador) {
                votosGanador=listaCandidatos[i].votos;
                ganador[votosGanador]=listaCandidatos[i].nombre;
            } 
        }
        emit ganadorDeclarado("EL GANADOR HA SIDO DECLARADO");
        return ganador[votosGanador];
    } 
}
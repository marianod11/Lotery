// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.8.0;
pragma experimental ABIEncoderV2;

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}



interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf (address account) external view returns (uint256);
    function allowance(address owner,address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferencia_loteria(address sender, address recipient, uint256 amount) external returns (bool);
    function approve (address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Basic is IERC20 {
    string public constant name = "ERC20Basic";
    string public constant symbol = "JBJ-TOKEN";
    uint8 public constant decimals = 2;
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    mapping (address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;
    uint256 totalSupply_;
    
    using SafeMath for uint256;
    
    constructor (uint256 total) public{
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }
    
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }
    
    function increaseTotalSuply(uint newTokens) public{
        totalSupply_ += newTokens;
        balances[msg.sender] += newTokens;
    }
    
    function balanceOf (address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }
    
    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender,receiver,numTokens);
        return true;
    } 
    
    function transferencia_loteria(address sender, address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[sender]);
        balances[sender] = balances[sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(sender,receiver,numTokens);
        return true;
    } 
    
    function approve (address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function allowance (address owner, address delegate) public override view returns (uint){
        return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require (numTokens <= balances[owner]);
        require (numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner,buyer,numTokens);
        return true;
    }
}



contract Loteria {

    ERC20Basic private token;


    address public owner;
    address public contrato;

    uint public tokens_creados = 10000;

    constructor() public{
        token = new ERC20Basic(tokens_creados);
        owner = msg.sender;
        contrato = address(this);
    }


   modifier Unicomente (address _direccion){
        require(_direccion == owner);
        _;
    }

    event compra_boletos(uint, address);


    // --------- comprar token --------------

    function precioToken(uint _numToken) internal pure returns(uint){
        return _numToken * (1 ether);
    }


    function generarToken (uint _numToken) public Unicomente(msg.sender){
        token.increaseTotalSuply(_numToken);
    }

    function comprarTokens (uint _numToken) public payable {
        uint coste = precioToken(_numToken);
        require (msg.value >= coste, "mas tokennnssssss");
        uint returnValue = msg.value - coste;
        msg.sender.transfer(returnValue);

        uint balance = tokenDisponilbe();
        require (_numToken <= balance, "compra menos tokens");

        token.transfer(msg.sender, _numToken);

        emit compra_boletos(_numToken, msg.sender);

    }

    function tokenDisponilbe() public view returns(uint){
        return token.balanceOf(contrato);
    }


    //balance de tokens acumulados
    function bote() public view returns(uint){
        return token.balanceOf(owner);
    }


    function misToken() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    //--------------- loteriaa------------------


    uint public prcioBoleto = 5;

    mapping(address => uint[]) idPersona_boleto;

    mapping(uint => address) adn_boleto;

    uint reamdomNum = 0;

    uint[] boletos_comprados;
    
    event boleto_comprado(uint, address);
    event boleto_ganador(uint);



    function comprarBoleto(uint _numBoleto) public {
        //precio total boletos
        uint precio_total = _numBoleto * prcioBoleto ;

        //filtrar tokens de pago
        require(precio_total <= misToken(), "necesitas mas tokens");

        //trasferencia al owner -> bote

        token.transferencia_loteria(msg.sender, owner, precio_total );
        
        //numero ramdomm
        for(uint i = 0 ; i < _numBoleto; i++){
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, reamdomNum))) % 10000;
            reamdomNum++;
            //almacenar los boletos
            idPersona_boleto[msg.sender].push(random);
            //alamcenaar boletos ya comprados
            boletos_comprados.push(random);
            //asignaar adn al aganador
            adn_boleto[random]= msg.sender;
            emit boleto_comprado(random, msg.sender);
        }
    }

    //ver tus boletos
    function verBoletos() public view returns(uint[] memory) {
        return idPersona_boleto[msg.sender];
    }

    function generarGnador() public  Unicomente(msg.sender){
        require(boletos_comprados.length > 0 ,"no compro nadiee");

        uint longituda = boletos_comprados.length;
        //aleteoria eligo entre 0 - lomgitud;
        uint posicion_array = uint (uint(keccak256(abi.encodePacked(now))) %longituda );
        // seleccion numero alaetorio

        uint eleccion = boletos_comprados[posicion_array];

        emit boleto_ganador(eleccion);
        //enviar tokens al ganador
        address direccion_ganador = adn_boleto[eleccion];
        
        token.transferencia_loteria(msg.sender, direccion_ganador, bote()*80 % 100);

    }


    //cambiar tokens por ethe

    function devolverTokens(uint _numToken) public payable {
        require (_numToken > 0, "necesitas mas tokenss");
        require(_numToken <= misToken(), "nos tienesn los tokens q quieres devolver");
        token.transferencia_loteria(msg.sender, address(this), _numToken);
        msg.sender.transfer(precioToken(_numToken));
    }

}


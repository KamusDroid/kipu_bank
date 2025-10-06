// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title KipuBank
 * @notice Bóveda simple de ETH con límite global (bankCap) y tope de retiro por transacción.
 * @dev Contrato educativo orientado a buenas prácticas (no usar en producción).
 */
contract KipuBank {
    /*//////////////////////////////////////////////////////////////
                                Estado
    //////////////////////////////////////////////////////////////*/

    /// @notice Límite global de depósitos (suma de todos los balances) en wei.
    uint256 public immutable i_bankCap;

    /// @notice Tope máximo de retiro por transacción en wei.
    uint256 public immutable i_withdrawalCapPerTx;

    /// @notice Balance por usuario.
    mapping(address => uint256) private s_balances;

    /// @notice Suma de todos los balances (para chequear contra i_bankCap).
    uint256 private s_totalBalance;

    /// @notice Contadores globales de operaciones.
    uint256 public s_totalDepositsCount;
    uint256 public s_totalWithdrawalsCount;

    /// @notice Contadores por usuario (opcional).
    mapping(address => uint256) public s_userDepositsCount;
    mapping(address => uint256) public s_userWithdrawalsCount;

    /*//////////////////////////////////////////////////////////////
                                 Errores
    //////////////////////////////////////////////////////////////*/

    /// @notice Error cuando se intenta operar con monto cero.
    error KipuBank_ZeroAmount();

    /// @notice Error cuando un depósito superaría el límite global.
    error KipuBank_DepositCapExceeded(uint256 cap, uint256 current, uint256 attempted);

    /// @notice Error cuando se intenta retirar más del tope por transacción.
    error KipuBank_WithdrawalCapExceeded(uint256 cap, uint256 requested);

    /// @notice Error cuando un usuario no posee balance suficiente.
    error KipuBank_InsufficientBalance(uint256 available, uint256 requested);

    /// @notice Error cuando los parámetros del constructor son inválidos.
    error KipuBank_InvalidConstructorParams();

    /// @notice Error cuando la transferencia de ETH falla.
    error KipuBank_TransferFailed(bytes lowLevelError);

    /*//////////////////////////////////////////////////////////////
                                  Eventos
    //////////////////////////////////////////////////////////////*/

    /// @notice Emite cada vez que un usuario deposita.
    event KipuBank_Deposited(address indexed account, uint256 amount, uint256 newBalance);

    /// @notice Emite cada vez que un usuario retira.
    event KipuBank_Withdrawn(address indexed account, uint256 amount, uint256 newBalance);

    /*//////////////////////////////////////////////////////////////
                               Constructor
    //////////////////////////////////////////////////////////////*/

    /**
     * @param bankCap Límite global de depósitos (wei).
     * @param withdrawalCapPerTx Tope de retiro por transacción (wei).
     */
    constructor(uint256 bankCap, uint256 withdrawalCapPerTx) {
        if (bankCap == 0 || withdrawalCapPerTx == 0) {
            revert KipuBank_InvalidConstructorParams();
        }
        i_bankCap = bankCap;
        i_withdrawalCapPerTx = withdrawalCapPerTx;
    }

    /*//////////////////////////////////////////////////////////////
                                Modificadores
    //////////////////////////////////////////////////////////////*/

    /// @notice Requiere que el monto sea distinto de cero.
    modifier nonZero(uint256 amount) {
        if (amount == 0) {
            revert KipuBank_ZeroAmount();
        }
        _;
    }

    /// @notice Requiere que el monto solicitado sea menor o igual al tope de retiro.
    modifier underWithdrawCap(uint256 amount) {
        if (amount > i_withdrawalCapPerTx) {
            revert KipuBank_WithdrawalCapExceeded(i_withdrawalCapPerTx, amount);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                          Funciones de interacción
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposita ETH en tu bóveda.
    function deposit() external payable nonZero(msg.value) {
        if (s_totalBalance + msg.value > i_bankCap) {
            revert KipuBank_DepositCapExceeded(i_bankCap, s_totalBalance, msg.value);
        }

        s_balances[msg.sender] += msg.value;
        s_totalBalance += msg.value;

        unchecked {
            ++s_totalDepositsCount;
            ++s_userDepositsCount[msg.sender];
        }

        emit KipuBank_Deposited(msg.sender, msg.value, s_balances[msg.sender]);
    }

    /**
     * @notice Retira un monto de tu bóveda (respetando el tope por transacción).
     * @param amount Monto a retirar (wei).
     */
    function withdraw(uint256 amount)
        external
        nonZero(amount)
        underWithdrawCap(amount)
    {
        uint256 balance = s_balances[msg.sender];
        if (balance < amount) {
            revert KipuBank_InsufficientBalance(balance, amount);
        }

        s_balances[msg.sender] = balance - amount;
        s_totalBalance -= amount;

        unchecked {
            ++s_totalWithdrawalsCount;
            ++s_userWithdrawalsCount[msg.sender];
        }

        emit KipuBank_Withdrawn(msg.sender, amount, s_balances[msg.sender]);

        _transferETH(payable(msg.sender), amount);
    }

    /*//////////////////////////////////////////////////////////////
                           Funciones de lectura
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Devuelve info de una bóveda.
     * @param user Dirección a consultar.
     * @return balance Balance almacenado del usuario (wei).
     * @return deposits Cantidad de depósitos realizados por el usuario.
     * @return withdrawals Cantidad de retiros realizados por el usuario.
     */
    function getVault(address user)
        external
        view
        returns (uint256 balance, uint256 deposits, uint256 withdrawals)
    {
        return (s_balances[user], s_userDepositsCount[user], s_userWithdrawalsCount[user]);
    }

    /// @notice Capacidad restante global antes de alcanzar el bankCap.
    function getRemainingBankCapacity() external view returns (uint256) {
        return i_bankCap - s_totalBalance;
    }

    /*//////////////////////////////////////////////////////////////
                          Funciones privadas
    //////////////////////////////////////////////////////////////*/

    /// @notice Envía ETH y revierte si falla.
    /// @param to Destinatario del envío.
    /// @param amount Monto a transferir (wei).
    function _transferETH(address payable to, uint256 amount) private {
        (bool success, bytes memory errorData) = to.call{value: amount}("");
        if (!success) {
            revert KipuBank_TransferFailed(errorData);
        }
    }

    /*//////////////////////////////////////////////////////////////
                         Receive (opcional)
    //////////////////////////////////////////////////////////////*/

    /// @notice Permite recibir ETH directamente respetando el límite global.
    receive() external payable {
        if (msg.value == 0) {
            revert KipuBank_ZeroAmount();
        }
        if (s_totalBalance + msg.value > i_bankCap) {
            revert KipuBank_DepositCapExceeded(i_bankCap, s_totalBalance, msg.value);
        }

        s_balances[msg.sender] += msg.value;
        s_totalBalance += msg.value;

        unchecked {
            ++s_totalDepositsCount;
            ++s_userDepositsCount[msg.sender];
        }

        emit KipuBank_Deposited(msg.sender, msg.value, s_balances[msg.sender]);
    }
}

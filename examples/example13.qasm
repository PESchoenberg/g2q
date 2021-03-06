// example13.qasm;
// Compiled with g2q - v1.2.9;
OPENQASM 2.0;
include "qelib1.inc";
qreg q[3];
creg c[3];
h q[0];
h q[1];
h q[2];
// Begin cswap;
cx q[2],q[1];
cx q[0],q[1];
h q[2];
t q[0];
tdg q[1];
t q[2];
cx q[2],q[1];
cx q[0],q[2];
t q[1];
tdg q[2];
cx q[0],q[1];
tdg q[1];
cx q[0],q[2];
cx q[2],q[1];
t q[1];
h q[2];
cx q[2],q[1];
// End cswap;
// Begin qmeasy;
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
// End qmeasy;
// qdeclare qx-simulator error_model depolarizing_channel,0.001;
// qdeclare qlib-simulator // Hello qlib-simulator;

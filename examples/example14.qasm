// example14.qasm;
// Compiled with g2q - v1.2.4;
OPENQASM 2.0;
include "qelib1.inc";
qreg q[5];
creg c[5];
h q[0];
h q[1];
h q[2];
h q[3];
h q[4];
// Begin cx-ladder;
cx q[0],q[1];
cx q[1],q[2];
cx q[2],q[3];
cx q[3],q[4];
// End cx-ladder;
// Begin cx-ladder;
cx q[3],q[4];
cx q[2],q[3];
cx q[1],q[2];
cx q[0],q[1];
// End cx-ladder;
// Begin cx-ladder;
cx q[1],q[0];
cx q[2],q[1];
cx q[3],q[2];
cx q[4],q[3];
// End cx-ladder;
// Begin cx-ladder;
cx q[4],q[3];
cx q[3],q[2];
cx q[2],q[1];
cx q[1],q[0];
// End cx-ladder;
// Begin qmeasy;
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
measure q[3] -> c[3];
measure q[4] -> c[4];
// End qmeasy;
// qdeclare qx-simulator error_model depolarizing_channel,0.001;
// qdeclare qlib-simulator // Hello qlib-simulator;

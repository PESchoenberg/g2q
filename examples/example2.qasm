// example2.qasm;
// Compiled with g2q - v1.2.5;
OPENQASM 2.0;
include "qelib1.inc";
qreg q[2];
creg c[1];
h q[0];
cx q[1],q[0];
// Measuring;
measure q[0] -> c[0];

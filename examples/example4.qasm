// example4.qasm
//
OPENQASM 2.0;
include "qelib1.inc";
//
qreg q[3];
creg c[3];
h q[0];
h q[1];
h q[2];
id q[0];
id q[1];
id q[2];
id q[0];
id q[1];
id q[2];
id q[0];
id q[1];
id q[2];
id q[0];
id q[1];
id q[2];
id q[0];
id q[1];
id q[2];
// 
// Measuring
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];

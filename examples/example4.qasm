// example4.qasm;
// Compiled with g2q - v1.2.5;
OPENQASM 2.0;
include "qelib1.inc";
qreg q[5];
creg c[5];
// Begin g1y;
h q[0];
h q[1];
h q[2];
h q[3];
h q[4];
// End g1y;
// Begin g1xy;
// Begin g1y;
id q[0];
id q[1];
id q[2];
id q[3];
id q[4];
// End g1y;
// Begin g1y;
id q[0];
id q[1];
id q[2];
id q[3];
id q[4];
// End g1y;
// Begin g1y;
id q[0];
id q[1];
id q[2];
id q[3];
id q[4];
// End g1y;
// Begin g1y;
id q[0];
id q[1];
id q[2];
id q[3];
id q[4];
// End g1y;
// Begin g1y;
id q[0];
id q[1];
id q[2];
id q[3];
id q[4];
// End g1y;
// End g1xy;
// Measuring;
// Begin qmeasy;
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
measure q[3] -> c[3];
measure q[4] -> c[4];
// End qmeasy;

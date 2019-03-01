// This program does nothing in particular, but shows how to use g2q functions.;
// example1.qasm;
// Compiled with g2q - v2.0.0;
OPENQASM 2.0;
include "qelib1.inc";
qreg q[5];
creg c[5];
// Five h gates.;
h q[0];
h q[1];
h q[2];
h q[3];
h q[4];
// Two x gates.;
x q[1];
x q[2];
// Various basic gates.;
id q[3];
y q[4];
z q[0];
s q[1];
t q[2];
tdg q[3];
sdg q[4];
u1(1.6) q[0];
u2(1.6,1.6) q[1];
u3(1.6,1.6,1.6) q[2];
// Controlled x.;
cx q[2],q[0];
// Controlled y.;
sdg q[4];
cx q[3],q[4];
s q[4];
// Controlled z.;
h q[2];
cx q[4],q[2];
h q[2];
// Controlled h.;
h q[0];
sdg q[0];
cx q[2],q[0];
h q[0];
t q[0];
cx q[2],q[0];
t q[0];
h q[0];
s q[0];
x q[0];
s q[2];
// Controlled x.;
u3(1.6,-1.570795,1.570795) q[1];
// Controlled y.;
u3(1.6,0,0) q[2];
// Controlled z.;
u1(1.6) q[3];
// crz.;
u1(0.8) q[4];
cx q[3],q[4];
u1(-0.8) q[4];
cx q[3],q[4];
// Controlled u1.;
u1(0.8) q[2];
cx q[2],q[0];
u1(-0.8) q[0];
cx q[2],q[0];
u1(0.8) q[2];
// Controlled u3.;
u1(0.0) q[0];
cx q[2],q[0];
u3(-0.8,0,-1.6) q[0];
cx q[2],q[0];
u3(0.8,1.6,0) q[0];
// Conditional1 eq.;
if(q==1) y q[2];
// Conditional2 eq.;
if(q[2]!=1) y q[2];
// Barriers.;
barrier q[0];
barrier q[1];
barrier q[2];
barrier q[3];
barrier q[4];
// Measuring;
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
measure q[3] -> c[3];
measure q[4] -> c[4];
// This message will appear at the end of the qasm file.;

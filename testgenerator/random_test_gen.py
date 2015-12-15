#!/usr/bin/python
import random
instruction=['lda', 'ldq', 'stq', 'cmpeq', 'cmplt', 'cmple', 'cmpult', 'cmpule', 'addq', 'subq', 'mulq', 'and', 'bic', 'bis', 'ornot', 'xor', 'eqv', 'srl', 'sll', 'sra']
line_count = 0
for i in range(100):
    f = open('testcase%d.s' % i, 'w')
    f.write('\tdata = 0x0008\n\tbr\tstart\n\t.quad 0\nstart:\tlda\t$r0,data\n\tstq\t$r31,0($r0)\n')
    while line_count < 16000:
        instr_index = random.randint(0, len(instruction)-1)
        op = instruction[instr_index]
        if op == 'ldq' or op == 'stq':
            addr_reg = '$r%d' % random.randint(0,30)
            while (addr_reg == '$r28'):
                addr_reg = '$r%d' % random.randint(0,30)
            line = '\tlda\t%s,data\n' % addr_reg
            f.write(line)
            regA = '$r%d' %random.randint(0,31)
            while (regA == '$r28'):
                regA = '$r%d' % random.randint(0,31)
            line = '\t{0}\t{1},0({2})\n'.format(op, regA, addr_reg)
            f.write(line)
            line_count = line_count + 2
        elif op == 'lda':
            dest_reg = '$r%d' %random.randint(0,31)
            while (dest_reg == '$r28'):
                dest_reg = '$r%d' % random.randint(0,31)
            number   = '0x%x' % random.randint(0,65535)
            line = '\t{0}\t{1},data\n'.format(op, dest_reg)
            f.write(line)
            line_count = line_count + 1
        else:
            reg_or_imm = random.randint(0,1)
            dest_reg = '$r%d' %random.randint(0,31)
            while (dest_reg == '$r28'):
                dest_reg = '$r%d' % random.randint(0,31)
            oprandA  = '$r%d' %random.randint(0,31)
            while (oprandA == '$r28'):
                oprandA = '$r%d' % random.randint(0,31)
            oprandB  = ''
            if reg_or_imm == 1 and (op == 'addq' or op == 'subq' or op == 'mulq'):
                oprandB = '0x%x' % random.randint(0, 7)
            else:
                oprandB = '$r%d' %random.randint(0,31)
                while (oprandB == '$r28'):
                    oprandB = '$r%d' % random.randint(0,31)
            line = '\t{0}\t{1},{2},{3}\n'.format(op, oprandA, oprandB, dest_reg)
            f.write(line)
            line_count = line_count + 1
    line_count = 0
    f.write('\tcall_pal 0x555\n')
    f.close()
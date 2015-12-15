 
****************************************
Report : resources
Design : processor
Version: K-2015.06
Date   : Sun Nov 22 16:14:25 2015
****************************************

Resource Sharing Report for design processor in file
        /home/xmguo/Documents/EECS573/Project/verilog/mem_arbiter.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r4041    | DW01_cmp6    | width=16   |               | mem_arbiter_0/eq_50_3 |
          |              |            |               | mem_arbiter_0/eq_61_3 |
| r4044    | DW01_cmp6    | width=4    |               | core0/icache_ctrl_0/eq_176 |
     |              |            |               | core0/icache_ctrl_0/eq_48 |
      |              |            |               | core0/icache_ctrl_0/eq_74 |
| r4048    | DW01_add     | width=64   |               | core0/icache_ctrl_0/add_128_I2 |
 |              |            |               | core0/icache_ctrl_0/add_133_I2 |
| r4049    | DW01_add     | width=64   |               | core0/icache_ctrl_0/add_128_I3 |
 |              |            |               | core0/icache_ctrl_0/add_133_I3 |
| r4050    | DW01_add     | width=64   |               | core0/icache_ctrl_0/add_128_I4 |
 |              |            |               | core0/icache_ctrl_0/add_133_I4 |
| r4194    | DW01_ash     | A_width=64 |               | core0/id_stage_0/PRF_freelist/sll_413 |
         |            |               |                      |
|          |              | SH_width=6 |               | core0/id_stage_0/PRF_validlist/sll_646 |
| r4197    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/eq_267 |
           |            |               |                      |
|          |              |            |               | core0/rs_stage_0/reservation/eq_296 |
| r4198    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/eq_268 |
           |            |               |                      |
|          |              |            |               | core0/rs_stage_0/reservation/eq_297 |
| r4218    | DW01_ash     | A_width=32 |               | core0/rs_stage_0/reorder/sll_680 |
              |            |               |                      |
|          |              | SH_width=5 |               | core0/rs_stage_0/reorder/sll_681 |
| r4260    | DW_rash      | A_width=64 |               | core0/ex_stage_0/alu_0/srl_300 |
 |              | SH_width=6 |               | core0/ex_stage_0/alu_0/srl_302 |
| r4264    | DW01_cmp6    | width=64   |               | core0/ex_stage_0/alu_0/eq_306 |
  |              |            |               | core0/ex_stage_0/alu_0/lt_284_C308 |
            |            |               |                      |
|          |              |            |               | core0/ex_stage_0/alu_0/lt_284_C309 |
            |            |               |                      |
|          |              |            |               | core0/ex_stage_0/alu_0/lt_305 |
  |              |            |               | core0/ex_stage_0/alu_0/lte_307 |
| r4282    | DW01_cmp6    | width=5    |               | core0/lsq_0/LDQ_0/eq_481 |
       |              |            |               | core0/lsq_0/LDQ_0/eq_527 |
| r4283    | DW01_cmp6    | width=5    |               | core0/lsq_0/LDQ_0/eq_481_I2 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_527_I2 |
| r4284    | DW01_cmp6    | width=5    |               | core0/lsq_0/LDQ_0/eq_481_I3 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_527_I3 |
| r4285    | DW01_cmp6    | width=5    |               | core0/lsq_0/LDQ_0/eq_481_I4 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_527_I4 |
| r4286    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_530 |
       |              |            |               | core0/lsq_0/LDQ_0/eq_530_I2 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_530_I3 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_530_I4 |
| r4287    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/ne_533 |
       |              |            |               | core0/lsq_0/LDQ_0/ne_533_I2 |
    |              |            |               | core0/lsq_0/LDQ_0/ne_533_I3 |
    |              |            |               | core0/lsq_0/LDQ_0/ne_533_I4 |
| r4288    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_530_I2_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I2_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I2_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I2_I4 |
| r4289    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/ne_533_I2_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I2_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I2_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I2_I4 |
| r4290    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_530_I3_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I3_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I3_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I3_I4 |
| r4291    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/ne_533_I3_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I3_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I3_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I3_I4 |
| r4292    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_530_I4_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I4_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I4_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_530_I4_I4 |
| r4293    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/ne_533_I4_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I4_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I4_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/ne_533_I4_I4 |
| r4294    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_547 |
       |              |            |               | core0/lsq_0/LDQ_0/eq_547_I2_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I3_I1 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I4_I1 |
| r4295    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_547_I2 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_547_I2_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I3_I2 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I4_I2 |
| r4296    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_547_I2_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I3 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_547_I3_I3 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I4_I3 |
| r4297    | DW01_cmp6    | width=16   |               | core0/lsq_0/LDQ_0/eq_547_I2_I4 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I3_I4 |
 |              |            |               | core0/lsq_0/LDQ_0/eq_547_I4 |
    |              |            |               | core0/lsq_0/LDQ_0/eq_547_I4_I4 |
| r4299    | DW01_cmp6    | width=5    |               | core0/lsq_0/STQ_0/eq_631 |
       |              |            |               | core0/lsq_0/STQ_0/eq_639 |
       |              |            |               | core0/lsq_0/STQ_0/eq_643 |
       |              |            |               | core0/lsq_0/STQ_0/eq_671 |
       |              |            |               | core0/lsq_0/STQ_0/eq_733 |
| r4302    | DW01_cmp6    | width=5    |               | core0/lsq_0/STQ_0/eq_724 |
       |              |            |               | core0/lsq_0/STQ_0/eq_745 |
| r4303    | DW01_cmp6    | width=5    |               | core0/lsq_0/STQ_0/eq_724_I2 |
    |              |            |               | core0/lsq_0/STQ_0/eq_745_I2 |
| r4304    | DW01_cmp6    | width=5    |               | core0/lsq_0/STQ_0/eq_724_I3 |
    |              |            |               | core0/lsq_0/STQ_0/eq_745_I3 |
| r4305    | DW01_cmp6    | width=5    |               | core0/lsq_0/STQ_0/eq_724_I4 |
    |              |            |               | core0/lsq_0/STQ_0/eq_745_I4 |
| r4307    | DW01_cmp6    | width=4    |               | core0/dctrl/eq_134_3 |
|          |              |            |               | core0/dctrl/eq_286   |
|          |              |            |               | core0/dctrl/eq_380_2 |
| r4308    | DW01_cmp6    | width=3    |               | core0/dctrl/eq_137_2 |
|          |              |            |               | core0/dctrl/ne_146   |
| r4309    | DW01_cmp6    | width=13   |               | core0/dctrl/eq_227_4 |
|          |              |            |               | core0/dctrl/eq_243   |
|          |              |            |               | core0/dctrl/eq_308   |
|          |              |            |               | core0/dctrl/eq_319   |
|          |              |            |               | core0/dctrl/eq_351_2 |
|          |              |            |               | core0/dctrl/eq_353   |
|          |              |            |               | core0/dctrl/eq_355   |
| r4545    | DW01_cmp6    | width=16   |               | core0/eq_957         |
| r4547    | DW01_cmp6    | width=16   |               | core0/eq_971         |
| r4549    | DW01_cmp6    | width=64   |               | core0/icache_ctrl_0/ne_50 |
| r4551    | DW01_inc     | width=2    |               | core0/icache_ctrl_0/add_75 |
| r4553    | DW01_inc     | width=2    |               | core0/icache_ctrl_0/add_95 |
| r4555    | DW01_add     | width=64   |               | core0/if_stage_0/add_57 |
| r4557    | DW01_ash     | A_width=64 |               | core0/if_stage_0/branch_predictor/sll_301 |
     |            |               |                      |
|          |              | SH_width=6 |               |                      |
| r4559    | DW01_ash     | A_width=64 |               | core0/if_stage_0/branch_predictor/sll_302 |
     |            |               |                      |
|          |              | SH_width=6 |               |                      |
| r4561    | DW01_ash     | A_width=64 |               | core0/if_stage_0/branch_predictor/sll_304 |
     |            |               |                      |
|          |              | SH_width=6 |               |                      |
| r4563    | DW01_ash     | A_width=64 |               | core0/if_stage_0/branch_predictor/sll_305 |
     |            |               |                      |
|          |              | SH_width=6 |               |                      |
| r4565    | DW01_ash     | A_width=32 |               | core0/if_stage_0/branch_target_buffer/sll_155 |
 |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4567    | DW01_ash     | A_width=32 |               | core0/if_stage_0/branch_target_buffer/sll_156 |
 |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4569    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[0]/eq_208 |
| r4571    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[0]/eq_214 |
| r4573    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[0]/eq_223 |
| r4575    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[0]/eq_225 |
| r4577    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[1]/eq_208 |
| r4579    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[1]/eq_214 |
| r4581    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[1]/eq_223 |
| r4583    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[1]/eq_225 |
| r4585    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[2]/eq_208 |
| r4587    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[2]/eq_214 |
| r4589    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[2]/eq_223 |
| r4591    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[2]/eq_225 |
| r4593    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[3]/eq_208 |
| r4595    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[3]/eq_214 |
| r4597    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[3]/eq_223 |
| r4599    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[3]/eq_225 |
| r4601    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[4]/eq_208 |
| r4603    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[4]/eq_214 |
| r4605    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[4]/eq_223 |
| r4607    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[4]/eq_225 |
| r4609    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[5]/eq_208 |
| r4611    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[5]/eq_214 |
| r4613    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[5]/eq_223 |
| r4615    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[5]/eq_225 |
| r4617    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[6]/eq_208 |
| r4619    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[6]/eq_214 |
| r4621    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[6]/eq_223 |
| r4623    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[6]/eq_225 |
| r4625    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[7]/eq_208 |
| r4627    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[7]/eq_214 |
| r4629    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[7]/eq_223 |
| r4631    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[7]/eq_225 |
| r4633    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[8]/eq_208 |
| r4635    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[8]/eq_214 |
| r4637    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[8]/eq_223 |
| r4639    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[8]/eq_225 |
| r4641    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[9]/eq_208 |
| r4643    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[9]/eq_214 |
| r4645    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[9]/eq_223 |
| r4647    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[9]/eq_225 |
| r4649    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[10]/eq_208 |
| r4651    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[10]/eq_214 |
| r4653    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[10]/eq_223 |
| r4655    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[10]/eq_225 |
| r4657    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[11]/eq_208 |
| r4659    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[11]/eq_214 |
| r4661    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[11]/eq_223 |
| r4663    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[11]/eq_225 |
| r4665    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[12]/eq_208 |
| r4667    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[12]/eq_214 |
| r4669    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[12]/eq_223 |
| r4671    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[12]/eq_225 |
| r4673    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[13]/eq_208 |
| r4675    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[13]/eq_214 |
| r4677    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[13]/eq_223 |
| r4679    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[13]/eq_225 |
| r4681    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[14]/eq_208 |
| r4683    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[14]/eq_214 |
| r4685    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[14]/eq_223 |
| r4687    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[14]/eq_225 |
| r4689    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[15]/eq_208 |
| r4691    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[15]/eq_214 |
| r4693    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[15]/eq_223 |
| r4695    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[15]/eq_225 |
| r4697    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[16]/eq_208 |
| r4699    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[16]/eq_214 |
| r4701    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[16]/eq_223 |
| r4703    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[16]/eq_225 |
| r4705    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[17]/eq_208 |
| r4707    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[17]/eq_214 |
| r4709    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[17]/eq_223 |
| r4711    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[17]/eq_225 |
| r4713    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[18]/eq_208 |
| r4715    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[18]/eq_214 |
| r4717    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[18]/eq_223 |
| r4719    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[18]/eq_225 |
| r4721    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[19]/eq_208 |
| r4723    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[19]/eq_214 |
| r4725    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[19]/eq_223 |
| r4727    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[19]/eq_225 |
| r4729    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[20]/eq_208 |
| r4731    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[20]/eq_214 |
| r4733    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[20]/eq_223 |
| r4735    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[20]/eq_225 |
| r4737    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[21]/eq_208 |
| r4739    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[21]/eq_214 |
| r4741    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[21]/eq_223 |
| r4743    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[21]/eq_225 |
| r4745    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[22]/eq_208 |
| r4747    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[22]/eq_214 |
| r4749    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[22]/eq_223 |
| r4751    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[22]/eq_225 |
| r4753    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[23]/eq_208 |
| r4755    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[23]/eq_214 |
| r4757    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[23]/eq_223 |
| r4759    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[23]/eq_225 |
| r4761    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[24]/eq_208 |
| r4763    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[24]/eq_214 |
| r4765    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[24]/eq_223 |
| r4767    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[24]/eq_225 |
| r4769    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[25]/eq_208 |
| r4771    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[25]/eq_214 |
| r4773    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[25]/eq_223 |
| r4775    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[25]/eq_225 |
| r4777    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[26]/eq_208 |
| r4779    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[26]/eq_214 |
| r4781    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[26]/eq_223 |
| r4783    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[26]/eq_225 |
| r4785    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[27]/eq_208 |
| r4787    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[27]/eq_214 |
| r4789    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[27]/eq_223 |
| r4791    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[27]/eq_225 |
| r4793    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[28]/eq_208 |
| r4795    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[28]/eq_214 |
| r4797    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[28]/eq_223 |
| r4799    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[28]/eq_225 |
| r4801    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[29]/eq_208 |
| r4803    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[29]/eq_214 |
| r4805    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[29]/eq_223 |
| r4807    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[29]/eq_225 |
| r4809    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[30]/eq_208 |
| r4811    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[30]/eq_214 |
| r4813    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[30]/eq_223 |
| r4815    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[30]/eq_225 |
| r4817    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[31]/eq_208 |
| r4819    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[31]/eq_214 |
| r4821    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[31]/eq_223 |
| r4823    | DW01_cmp6    | width=11   |               | core0/if_stage_0/branch_target_buffer/BTB_32[31]/eq_225 |
| r4825    | DW01_cmp6    | width=6    |               | core0/id_stage_0/eq_745 |
| r4827    | DW01_cmp6    | width=6    |               | core0/id_stage_0/eq_747 |
| r4829    | DW01_ash     | A_width=32 |               | core0/id_stage_0/renaming_table/sll_238 |
       |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4831    | DW01_ash     | A_width=32 |               | core0/id_stage_0/renaming_table/sll_239 |
       |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4833    | DW01_ash     | A_width=32 |               | core0/id_stage_0/renaming_table/sll_240 |
       |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4835    | DW01_ash     | A_width=64 |               | core0/id_stage_0/recover_RAT/sll_314 |
          |            |               |                      |
|          |              | SH_width=6 |               |                      |
| r4837    | DW01_ash     | A_width=64 |               | core0/id_stage_0/recover_RAT/sll_315 |
          |            |               |                      |
|          |              | SH_width=6 |               |                      |
| r4839    | DW01_ash     | A_width=32 |               | core0/id_stage_0/recover_RAT/sll_316 |
          |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4841    | DW01_ash     | A_width=64 |               | core0/id_stage_0/PRF_validlist/sll_647 |
        |            |               |                      |
|          |              | SH_width=6 |               |                      |
| r4843    | DW01_inc     | width=3    |               | core0/id_stage_0/malicious/add_50 |
| r4845    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[0]/eq_434 |
| r4847    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[0]/eq_435 |
| r4849    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[1]/eq_434 |
| r4851    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[1]/eq_435 |
| r4853    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[2]/eq_434 |
| r4855    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[2]/eq_435 |
| r4857    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[3]/eq_434 |
| r4859    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[3]/eq_435 |
| r4861    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[4]/eq_434 |
| r4863    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[4]/eq_435 |
| r4865    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[5]/eq_434 |
| r4867    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[5]/eq_435 |
| r4869    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[6]/eq_434 |
| r4871    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[6]/eq_435 |
| r4873    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[7]/eq_434 |
| r4875    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reservation/RS8[7]/eq_435 |
| r4877    | DW01_cmp6    | width=5    |               | core0/rs_stage_0/reorder/eq_674 |
| r4879    | DW01_ash     | A_width=32 |               | core0/rs_stage_0/reorder/sll_678 |
              |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4881    | DW01_ash     | A_width=32 |               | core0/rs_stage_0/reorder/sll_679 |
              |            |               |                      |
|          |              | SH_width=5 |               |                      |
| r4883    | DW01_inc     | width=5    |               | core0/rs_stage_0/reorder/add_724 |
| r4885    | DW01_inc     | width=5    |               | core0/rs_stage_0/reorder/add_735 |
| r4887    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[0]/eq_785 |
| r4889    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[1]/eq_785 |
| r4891    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[2]/eq_785 |
| r4893    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[3]/eq_785 |
| r4895    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[4]/eq_785 |
| r4897    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[5]/eq_785 |
| r4899    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[6]/eq_785 |
| r4901    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[7]/eq_785 |
| r4903    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[8]/eq_785 |
| r4905    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[9]/eq_785 |
| r4907    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[10]/eq_785 |
| r4909    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[11]/eq_785 |
| r4911    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[12]/eq_785 |
| r4913    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[13]/eq_785 |
| r4915    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[14]/eq_785 |
| r4917    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[15]/eq_785 |
| r4919    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[16]/eq_785 |
| r4921    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[17]/eq_785 |
| r4923    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[18]/eq_785 |
| r4925    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[19]/eq_785 |
| r4927    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[20]/eq_785 |
| r4929    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[21]/eq_785 |
| r4931    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[22]/eq_785 |
| r4933    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[23]/eq_785 |
| r4935    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[24]/eq_785 |
| r4937    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[25]/eq_785 |
| r4939    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[26]/eq_785 |
| r4941    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[27]/eq_785 |
| r4943    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[28]/eq_785 |
| r4945    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[29]/eq_785 |
| r4947    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[30]/eq_785 |
| r4949    | DW01_cmp6    | width=6    |               | core0/rs_stage_0/reorder/ROB32[31]/eq_785 |
| r4951    | DW01_cmp6    | width=16   |               | core0/ex_stage_0/ne_136 |
| r4953    | DW01_cmp6    | width=16   |               | core0/ex_stage_0/ne_136_2 |
| r4955    | DW01_cmp6    | width=6    |               | core0/ex_stage_0/regfile/eq_38 |
| r4957    | DW01_cmp6    | width=6    |               | core0/ex_stage_0/regfile/eq_47 |
| r4959    | DW01_cmp6    | width=6    |               | core0/ex_stage_0/regfile/eq_55 |
| r4961    | DW01_add     | width=64   |               | core0/ex_stage_0/alu_0/add_292 |
| r4963    | DW01_sub     | width=64   |               | core0/ex_stage_0/alu_0/sub_293 |
| r4965    | DW01_ash     | A_width=64 |               | core0/ex_stage_0/alu_0/sll_301 |
 |              | SH_width=6 |               |                      |
| r4967    | DW01_sub     | width=8    |               | core0/ex_stage_0/alu_0/sub_302 |
| r4969    | DW01_ash     | A_width=64 |               | core0/ex_stage_0/alu_0/sll_302 |
 |              | SH_width=32 |              |                      |
| r4971    | DW01_cmp6    | width=64   |               | core0/ex_stage_0/alu_0/eq_309 |
| r4973    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[0]/add_352 |
| r4977    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[1]/add_352 |
| r4981    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[2]/add_352 |
| r4985    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[3]/add_352 |
| r4989    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[4]/add_352 |
| r4993    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[5]/add_352 |
| r4997    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[6]/add_352 |
| r5001    | DW01_add     | width=64   |               | core0/ex_stage_0/mult/mstage[7]/add_352 |
| r5005    | DW01_cmp6    | width=2    |               | core0/lsq_0/STQ_0/eq_627 |
| r5007    | DW01_inc     | width=2    |               | core0/lsq_0/STQ_0/add_673 |
| r5009    | DW01_inc     | width=2    |               | core0/lsq_0/STQ_0/add_699 |
| r5011    | DW01_cmp6    | width=2    |               | core0/dctrl/eq_112   |
| r5113    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[7]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
| r5215    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[6]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
| r5317    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[5]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
| r5419    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[4]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
| r5521    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[3]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
| r5623    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[2]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
| r5725    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[1]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
| r5827    | DW02_mult    | A_width=8  |               | core0/ex_stage_0/mult/mstage[0]/mult_354 |
      |            |               |                      |
|          |              | B_width=64 |               |                      |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r4264              | DW01_cmp6        | rpl                |                |
| core0/ex_stage_0/mult/mstage[1]/add_352                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/mult/mstage[2]/add_352                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/mult/mstage[3]/add_352                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/mult/mstage[4]/add_352                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/mult/mstage[5]/add_352                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/mult/mstage[6]/add_352                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/mult/mstage[7]/add_352                    |                |
|                    | DW01_add         | cla                |                |
| core0/if_stage_0/add_57               |                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/alu_0/add_292        |                    |                |
|                    | DW01_add         | cla                |                |
| core0/ex_stage_0/alu_0/sub_293        |                    |                |
|                    | DW01_sub         | cla                |                |
| core0/ex_stage_0/mult/mstage[7]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/ex_stage_0/mult/mstage[6]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/ex_stage_0/mult/mstage[5]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/ex_stage_0/mult/mstage[4]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/ex_stage_0/mult/mstage[3]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/ex_stage_0/mult/mstage[2]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/ex_stage_0/mult/mstage[1]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/ex_stage_0/mult/mstage[0]/mult_354                   |                |
|                    | DW02_mult        | csa                |                |
| core0/if_stage_0/branch_predictor/sll_302                  |                |
|                    | DW01_ash         | mx2                |                |
| core0/if_stage_0/branch_predictor/sll_304                  |                |
|                    | DW01_ash         | mx2                |                |
| core0/if_stage_0/branch_target_buffer/sll_155              |                |
|                    | DW01_ash         | mx2                |                |
| core0/rs_stage_0/reorder/sll_679      |                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/icache_ctrl_0/ne_50             |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| core0/id_stage_0/recover_RAT/sll_316  |                    |                |
|                    | DW01_ash         | mx2                |                |
| r4194              | DW01_ash         | mx2                |                |
| r4218              | DW01_ash         | mx2                |                |
| r4260              | DW_rash          | mx2                |                |
| core0/if_stage_0/branch_predictor/sll_301                  |                |
|                    | DW01_ash         | mx2                |                |
| core0/if_stage_0/branch_predictor/sll_305                  |                |
|                    | DW01_ash         | mx2                |                |
| core0/if_stage_0/branch_target_buffer/sll_156              |                |
|                    | DW01_ash         | mx2                |                |
| core0/id_stage_0/renaming_table/sll_238                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/id_stage_0/renaming_table/sll_239                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/id_stage_0/renaming_table/sll_240                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/id_stage_0/recover_RAT/sll_314  |                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/id_stage_0/recover_RAT/sll_315  |                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/id_stage_0/PRF_validlist/sll_647                     |                |
|                    | DW01_ash         | mx2                |                |
| core0/rs_stage_0/reorder/sll_678      |                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/ex_stage_0/alu_0/sll_301        |                    |                |
|                    | DW01_ash         | mx2                |                |
| core0/ex_stage_0/alu_0/eq_309         |                    |                |
|                    | DW01_cmp6        | rpl                |                |
===============================================================================

 
****************************************
Design : processor_DW02_mult_0
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================

 
****************************************
Design : processor_DW02_mult_1
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : processor_DW02_mult_2
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : processor_DW02_mult_3
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : processor_DW02_mult_4
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : processor_DW02_mult_5
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : processor_DW02_mult_6
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : processor_DW02_mult_7
****************************************

Resource Sharing Report for design DW02_mult_A_width8_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=70   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

1

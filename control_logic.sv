`timescale 1ns / 1ps

module control_logic(
input logic [2:0] func3, 
input logic [4:0] op_code, 
input logic func7_30, 
output logic BSel, func7, w_en, wd_en, rd_en, Asel, BrUn, Branch, Jump,
output logic [2:0] ALUSel, 
output logic [2:0] op_sel, 
output logic [1:0] WBSel, 
output logic [2:0] IMMSel);
//Add branch and jump 
 always_comb begin
    case(op_code)
            5'b01100: begin // R-type
              BSel  = 1'b0;
              ALUSel = func3;
              func7  = func7_30;
              w_en   = 1'b1;
              op_sel = func3;
              wd_en = 1'b0;
              rd_en = 1'b0;
              WBSel = 2'b01;
              IMMSel = 3'b000;
              Asel = 1'b0;
              BrUn = 1'b0;
              Jump = 1'b0;
              Branch = 1'b0;              
            end
    
            5'b00100: begin // I-type
              BSel   = 1'b1;
              ALUSel = func3;
              case(func3)
                3'b101: func7 = func7_30;
                default: func7 = 1'b0;
              endcase
              w_en = 1'b1;
              IMMSel = 3'b001;
              op_sel = func3;
              wd_en = 1'b0;
              rd_en = 1'b0;
              WBSel = 2'b01;
              Asel = 1'b0;
              BrUn = 1'b0;
              Jump = 1'b0;
              Branch = 1'b0;              
            end
            
            5'b00000: begin //Load-type
            BSel = 1'b1;
            ALUSel = 3'b000;
            op_sel = func3;
            wd_en = 1'b0;
            w_en = 1'b1;
            rd_en = 1'b1;
            WBSel = 2'b00;
            IMMSel = 3'b001;
            func7 = 1'b0;
            Asel = 1'b0;
            BrUn = 1'b0;
            Jump = 1'b0;
            Branch = 1'b0;
            end
            
            5'b01000: begin //Store-type
            BSel = 1'b1;
            ALUSel = 3'b000;
            op_sel = func3;
            wd_en = 1'b1;
            rd_en = 1'b0;
            WBSel = 2'b01;
            IMMSel = 3'b000;
            w_en = 1'b0;
            func7 = 1'b0;
            Asel = 1'b0;
            BrUn = 1'b0;
            Jump = 1'b0;
            Branch = 1'b0;            
            end
    
            5'b11011: begin //J-type
                BSel = 1'b1;
                ALUSel = 3'b000;
                op_sel = func3;
                wd_en = 1'b0;
                rd_en = 1'b0;
                WBSel = 2'b10;
                IMMSel = 3'b010;
                w_en = 1'b1;
                func7 = 1'b0;
                Asel = 1'b1;
                BrUn = 1'b0;
                Jump = 1'b1;
                Branch = 1'b0;                
                end
     
            5'b11001: begin //Jalr-type
                  BSel = 1'b1;
                  ALUSel = 3'b000;
                  op_sel = func3;
                  wd_en = 1'b0;
                  rd_en = 1'b0;
                  WBSel = 2'b10;
                  IMMSel = 3'b001;
                  w_en = 1'b1;
                  func7 = 1'b0;
                  Asel = 1'b0;
                  BrUn = 1'b0;
                  Jump = 1'b1;
                  Branch = 1'b0;                  
                  end 
             5'b11000: begin //B-type
                  BSel = 1'b1;
                  ALUSel = 3'b000;
                  op_sel = func3;
                  wd_en = 1'b0;
                  rd_en = 1'b0;
                  WBSel = 2'b10;
                  IMMSel = 3'b011;
                  w_en = 1'b0;
                  func7 = 1'b0;
                  Asel = 1'b1;
                  case(func3)
                  3'b000: begin 
                            BrUn = 1'b0;
                          end 
                  3'b001: begin
                            BrUn = 1'b0;
                          end
                  3'b100: begin
                            BrUn = 1'b0;
                          end
                  3'b101: begin
                            BrUn = 1'b0;
                          end
                  3'b110: begin
                            BrUn = 1'b1;
                          end
                  3'b111: begin
                            BrUn = 1'b1;
                          end
                  default: BrUn = 1'b0;
                  endcase   
                  Jump = 1'b0;
                  Branch = 1'b1;                           
                  end
            5'b01101: begin //LUI
                BSel = 1'b1;
                ALUSel = 3'b001;
                op_sel = func3;
                wd_en = 1'b0;
                rd_en = 1'b0;
                WBSel = 2'b01;
                IMMSel = 3'b100;
                w_en = 1'b1;
                func7 = 1'b1;
                Asel = 1'b0;
                BrUn = 1'b0;
                Jump = 1'b0;
                Branch = 1'b0;                
                end                     
    
            5'b00101: begin //AUIPC
                BSel = 1'b1;
                ALUSel = 3'b000;
                op_sel = func3;
                wd_en = 1'b0;
                rd_en = 1'b0;
                WBSel = 2'b01;
                IMMSel = 3'b100;
                w_en = 1'b1;
                func7 = 1'b0;
                Asel = 1'b1;
                BrUn = 1'b0;
                Jump = 1'b0;
                Branch = 1'b0;
                end              
                             
            default: begin
              BSel    = 1'b0;
              ALUSel  = 3'b000;
              func7   = 1'b0;
              w_en    = 1'b0;
              wd_en   = 1'b0;
              rd_en   = 1'b0;
              WBSel   = 2'b00;
              IMMSel  = 3'b000;
              Asel = 1'b0;
              BrUn = 1'b0;
              Jump = 1'b0;
              Branch = 1'b0;
            end
          endcase
    end
endmodule

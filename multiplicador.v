module Multiplier #(
    parameter N = 4  // Definir o número de bits do multiplicador e multiplicando
) (
    input wire clk,
    input wire rst_n,

    input wire start,
    output reg ready,

    input wire [N-1:0] multiplier,   // O multiplicador (B)
    input wire [N-1:0] multiplicand,  // O multiplicando (A)
    output reg [2*N-1:0] product      // Resultado da multiplicação (R)
);

    // Registradores internos
    reg [N-1:0] A, B;               // Registradores para multiplicando e multiplicador
    reg [2*N-1:0] P;                // Registrador do produto
    reg [3:0] state;                // Estado para controle de ciclos

    // Definições do estado
    localparam IDLE = 4'b0001,        // Estado de espera
               LOAD = 4'b0010,        // Carregar A e B
               EXEC = 4'b0100,        // Executando a multiplicação
               DONE = 4'b1000;        // Operação finalizada

    // Controle de operação com base no start e no estado
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE;
            ready <= 0;
            product <= 0;
            A <= 0;
            B <= 0;
            P <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= LOAD; // Se start for ativado, começa a carregar os valores
                    end
                end

                LOAD: begin
                    A <= multiplicand;  // Carregar multiplicando (A)
                    B <= multiplier;    // Carregar multiplicador (B)
                    P <= 0;             // Inicializa o produto
                    state <= EXEC;      // Vai para o estado de execução
                end

                EXEC: begin
                    if (B[0]) begin
                        P <= P + A;     // Se o bit de B[0] for 1, soma A ao produto
                    end
                    A <= A << 1;        // Desloca A para a esquerda (multiplica por 2)
                    B <= B >> 1;        // Desloca B para a direita (divide por 2)
                    if (B == 0) begin
                        state <= DONE;  // Se B for zero, termina a operação
                    end
                end

                DONE: begin
                    product <= P;       // Atribui o produto final
                    ready <= 1;         // Sinaliza que o produto está pronto
                    state <= IDLE;      // Volta para o estado de espera
                end
            endcase
        end
    end

endmodule


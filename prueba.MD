stateDiagram-v2
    [*] --> IDLE : rst = 1

    IDLE --> IDLE : start = 0
    IDLE --> LOAD : start = 1

    note right of IDLE
        done = 0
    end note

    LOAD --> ADD : Incondicional (1 ciclo)

    note right of LOAD
        acc <= 0
        count <= 0
        done = 0
    end note

    ADD --> ADD : count < N - 1
    ADD --> DONE : count == N - 1

    note right of ADD
        acc <= acc + x
        count <= count + 1
        done = 0
    end note

    DONE --> IDLE : Incondicional (1 ciclo)

    note right of DONE
        done = 1
    end note
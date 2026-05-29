# AXI4-Lite Documentation

Custom AXI4-Lite Reference Guide

## Introduction

**AXI** stands for **Advanced eXtensible Interface**. It is a part of the **AMBA** (Advanced Microcontroller Bus Architecture) protocol suite developed by ARM.

**AXI4-Lite** is a simplified, lower-throughput version of the full AXI4 protocol, typically used for accessing simple control and status registers.

## The 5 Channels

AXI4-Lite uses 5 independent channels for communication:

### Write Architecture

- **AW (Write Address Channel):** Specifies the address where data should be written.
- **W (Write Data Channel):** Transfers the actual data to be written.
- **B (Write Response Channel):** Signals whether the write operation was successful.

### Read Architecture

- **AR (Read Address Channel):** Specifies the address to read from.
- **R (Read Data Channel):** Transfers the requested data back from that address.

## Signal Descriptions & Handshake Protocol

Independent of the channel type, all information transfer within the AXI4-Lite protocol is governed by a synchronous, two-wire **`VALID` / `READY` Handshake** mechanism.

### The Handshake Mechanism

Flow control is explicitly managed by two primary control signals per channel:

- **`VALID` (Driven by Source):** Asserted high (`1`) when valid payload data, addresses, or control indicators are stable and available on the bus.
- **`READY` (Driven by Destination):** Asserted high (`1`) when the target device is capable of accepting the transaction.

> ⚠️ **The Primary Handshake Rule:** A data transfer occurs on the rising edge of the global clock (`ACLK`) if and only if both `VALID` and `READY` are sampled High simultaneously. Once `VALID` is asserted, the source must not negate it or alter the payload data until the handshake completes.

## Bus Signal Configuration Matrix

The following tables outline the mandatory signal architecture required for an AXI4-Lite compliant interface.

### Global Signals

|**Signal Name**|**Direction**|**Width**|**Description**|
|---|---|---|---|
|**`ACLK`**|Input|1|Global Clock Signal. All input signals are sampled on the rising edge of `ACLK`.|
|**`ARESETn`**|Input|1|Global Reset Signal. Active-Low, synchronous to `ACLK`.|

### Write Interface Channels

#### 1. Write Address Channel (AW)

|**Signal Name**|**Width**|**Direction**|**Description**|
|---|---|---|---|
|**`AWADDR`**|32 / 64|Master $\rightarrow$ Slave|Write Address Bus. Specifies the target location for a write transaction.|
|**`AWPROT`**|3|Master $\rightarrow$ Slave|Protection Type. Denotes the privilege and security level of the transaction.|
|**`AWVALID`**|1|Master $\rightarrow$ Slave|Write Address Valid. Indicates that the write address is valid and stable.|
|**`AWREADY`**|1|Slave $\rightarrow$ Master|Write Address Ready. Indicates that the slave is ready to accept the address.|

#### 2. Write Data Channel (W)

|**Signal Name**|**Width**|**Direction**|**Description**|
|---|---|---|---|
|**`WDATA`**|32 / 64|Master $\rightarrow$ Slave|Write Data Bus. Carries the payload data to be written.|
|**`WSTRB`**|4 / 8|Master $\rightarrow$ Slave|Write Strobes. Byte-lane qualifiers specifying which byte lanes hold valid data.|
|**`WVALID`**|1|Master $\rightarrow$ Slave|Write Data Valid. Indicates that the write data payload is valid.|
|**`WREADY`**|1|Slave $\rightarrow$ Master|Write Data Ready. Indicates that the slave is ready to accept the data payload.|

#### 3. Write Response Channel (B)

|**Signal Name**|**Width**|**Direction**|**Description**|
|---|---|---|---|
|**`BRESP`**|2|Slave $\rightarrow$ Master|Write Response Status. Indicates the success or failure status of the write (`OKAY`, `SLVERR`, `DECERR`).|
|**`BVALID`**|1|Slave $\rightarrow$ Master|Write Response Valid. Indicates that the write response status is valid.|
|**`BREADY`**|1|Master $\rightarrow$ Slave|Write Response Ready. Indicates that the master is ready to accept the status response.|

### Read Interface Channels

#### 4. Read Address Channel (AR)

|**Signal Name**|**Width**|**Direction**|**Description**|
|---|---|---|---|
|**`ARADDR`**|32 / 64|Master $\rightarrow$ Slave|Read Address Bus. Specifies the target location for a read transaction.|
|**`ARPROT`**|3|Master $\rightarrow$ Slave|Protection Type. Denotes the privilege and security level of the read transaction.|
|**`ARVALID`**|1|Master $\rightarrow$ Slave|Read Address Valid. Indicates that the read address is valid and stable.|
|**`ARREADY`**|1|Slave $\rightarrow$ Master|Read Address Ready. Indicates that the slave is ready to accept the address.|

#### 5. Read Data Channel (R)

| **Signal Name** | **Width** | **Direction**              | **Description**                                                                                         |
| --------------- | --------- | -------------------------- | ------------------------------------------------------------------------------------------------------- |
| **`RDATA`**     | 32 / 64   | Slave $\rightarrow$ Master | Read Data Bus. Carries the requested payload data back to the master.                                   |
| **`RRESP`**     | 2         | Slave $\rightarrow$ Master | Read Response Status. Indicates the success or failure status of the read (`OKAY`, `SLVERR`, `DECERR`). |
| **`RVALID`**    | 1         | Slave $\rightarrow$ Master | Read Data Valid. Indicates that the read data payload and status are valid.                             |
| **`RREADY`**    | 1         | Master $\rightarrow$ Slave | Read Data Ready. Indicates that the master is ready to accept the data and status.                      |

## Reset and Initialization State

To ensure predictable system behavior and prevent immediate bus deadlock upon startup, the AXI4-Lite protocol enforces strict initialization rules during the reset phase.

### Reset Protocol Rules

- **Active-Low Protocol:** The global reset signal, **`ARESETn`**, is active-Low. It must be asserted Low for at least one full cycle of `ACLK` to guarantee proper initialization of the interface components.
- **Master/Slave Driving Requirements:** During the reset period, all source devices must drive their respective **`VALID`** signals Low (`0`).
- **Undetermined States:** Signals that are not flow-controlled by a handshake (such as `AWADDR`, `WDATA`, and `ARADDR`) are permitted to be in an undefined state during reset. They only need to become stable when their corresponding `VALID` signal is asserted High.

### Initial Reset Signal Values

The table below defines the required state of the interface control signals while `ARESETn` is asserted Low:

|**Signal Type**|**Signal Name**|**Mandatory Reset Value**|**Responsible Agent**|
|---|---|---|---|
|**Write Address**|`AWVALID`|`1'b0`|Master|
|**Write Data**|`WVALID`|`1'b0`|Master|
|**Write Response**|`BVALID`|`1'b0`|Slave|
|**Read Address**|`ARVALID`|`1'b0`|Master|
|**Read Data**|`RVALID`|`1'b0`|Slave|

> ⚠️ **Critical Implementation Note:** While `VALID` signals must be explicitly driven to `0`, a destination device is permitted to drive its corresponding `READY` signal (`AWREADY`, `WREADY`, `BREADY`, `ARREADY`, or `RREADY`) either High (`1`) or Low (`0`) during reset. However, keeping `READY` Low during reset is generally recommended to prevent premature handshakes on the clock cycle immediately following reset deassertion.

## Interface Dependencies & Handshake Relationships

To prevent permanent bus deadlock, the AXI4-Lite protocol defines strict rules regarding signal dependencies during a handshake. A deadlock occurs when a Master waits for a Slave to assert a signal while the Slave simultaneously waits for the Master, locking the bus indefinitely.

### Core Dependency Principles

- **`VALID` before `READY` Independence:** A source device (Master or Slave) **must never** wait for the destination to assert its `READY` signal before driving its own `VALID` signal High.
- **Preemptive `READY` Allowed:** A destination device is permitted to assert its `READY` signal _before_ the source asserts `VALID`. This optimizes performance by enabling single-cycle transfers.

### Write Transaction Dependencies

The AMBA specification enforces structural dependencies for write operations. Arrows indicate which signal assertion **must** occur before another can be required.

#### 1. Address and Data Phase

The Master can assert `AWVALID` and `WVALID` independently or simultaneously. The Slave is allowed to wait for these signals before responding.

```text
Master Signals                       Slave Signals

  AWVALID ───────────────────────────────> AWREADY

   WVALID ───────────────────────────────> WREADY
```

- **Rule:** `AWVALID` must not depend on `AWREADY`.
- **Rule:** `WVALID` must not depend on `WREADY`.

#### 2. Response Phase

The Slave **must wait** for both the address handshake and the data handshake to complete before it can issue a write response.

```text
Master Phase Completion              Slave Response

 AWVALID + AWREADY ──┐
                     ├─── [Internal] ───> BVALID ───> BREADY (Master)
  WVALID +  WREADY ──┘
```

- **Rule:** The Slave must not assert `BVALID` until both the `AW` phase (`AWVALID` and `AWREADY` are High) and the `W` phase (`WVALID` and `WREADY` are High) have successfully executed.
- **Rule:** The Master is allowed to wait for `BVALID` before it asserts `BREADY`.

### Read Transaction Dependencies

Read transactions follow a simpler sequential dependency structure.

```text
Master Address Phase                   Slave Data Phase

  ARVALID ─────────> ARREADY ─────────> RVALID ─────────> RREADY (Master)
```

- **Rule:** The Master must not wait for `ARREADY` before asserting `ARVALID`.
- **Rule:** The Slave can wait for `ARVALID` to go High before asserting `ARREADY`.
- **Rule:** The Slave **must wait** for both `ARVALID` and `ARREADY` to go High before it can assert `RVALID` to deliver the read data.
- **Rule:** The Master is allowed to wait for `RVALID` before it asserts `RREADY`.

## Transaction Timing Diagrams

To implement an AXI4-Lite master or slave interface in hardware (VHDL/Verilog), it is essential to understand how the handshake signals behave across clock cycles. The diagrams below illustrate a typical zero-wait-state write transaction and a read transaction with a standard one-cycle slave latency.

### 1. Write Transaction Timing

An AXI4-Lite write transaction requires the completion of both the Address (`AW`) and Data (`W`) channels before the Slave can respond on the Response (`B`) channel. In this optimized scenario, the Master drives the address and data simultaneously.

```Plaintext
               Cycle 1      Cycle 2      Cycle 3      Cycle 4
CLK         ___/¯¯¯¯¯\___/¯¯¯¯¯\___/¯¯¯¯¯\___/¯¯¯¯¯\___/¯¯¯¯¯\___
                       :            :            :
AWADDR                 :   ADDR     :            :
AWVALID     ___________/¯¯¯¯¯¯¯¯¯¯¯¯\____________________________
AWREADY     ________________________/¯¯¯¯¯¯¯¯¯¯¯¯\_______________ (Handshake AW)
                       :            :            :
WDATA                  :   DATA     :            :
WSTRB                  :   STRB     :            :
WVALID      ___________/¯¯¯¯¯¯¯¯¯¯¯¯\____________________________
WREADY      ________________________/¯¯¯¯¯¯¯¯¯¯¯¯\_______________ (Handshake W)
                       :            :            :
BRESP                  :            :   OKAY     :
BVALID      ________________________/¯¯¯¯¯¯¯¯¯¯¯¯\_______________
BREADY      ───────────────────────────────────────────────────── (Pre-asserted)
                                                 ^
                                          Transaction Completed
```

- **Cycle 1 to 2:** The Master asserts `AWVALID` and `WVALID` while placing the valid `ADDR` and `DATA` onto the bus.

- **Cycle 2 to 3:** The Slave asserts `AWREADY` and `WREADY`, indicating it has registered the write instructions. On the rising edge of Cycle 3, both the address and data handshakes occur simultaneously.
- **Cycle 3 to 4:** Because both phases completed successfully, the Slave drives the success status `OKAY` on `BRESP` and asserts `BVALID`. Since `BREADY` is already tied High by the Master, the write transaction completes cleanly on the rising edge of Cycle 4.

### 2. Read Transaction Timing

A read transaction consists of an Address Read (`AR`) phase followed by a Data Read (`R`) phase. The diagram below illustrates a slave that takes one clock cycle to decode the address and look up the data.

```Plaintext
               Cycle 1      Cycle 2      Cycle 3      Cycle 4
CLK         ___/¯¯¯¯¯\___/¯¯¯¯¯\___/¯¯¯¯¯\___/¯¯¯¯¯\___/¯¯¯¯¯\___
                       :            :            :
ARADDR                 :   ADDR     :            :
ARVALID     ___________/¯¯¯¯¯¯¯¯¯¯¯¯\____________________________
ARREADY     ________________________/¯¯¯¯¯¯¯¯¯¯¯¯\_______________ (Handshake AR)
                       :            :            :
RDATA                  :            :   DATA     :
RRESP                  :            :   OKAY     :
RVALID      ________________________/¯¯¯¯¯¯¯¯¯¯¯¯\_______________
RREADY      _____________________________________/¯¯¯¯¯¯¯¯¯¯¯¯\__ (Handshake R)
                                                 ^
                                          Data Transferred
```

- **Cycle 1 to 2:** The Master begins the transaction by presenting the target read address on `ARADDR` and asserting `ARVALID`.
- **Cycle 2 to 3:** The Slave asserts `ARREADY`, capturing the address on the rising edge of Cycle 3. This completes the address phase. The Master immediately lowers `ARVALID`.
- **Cycle 3 to 4:** The Slave internal logic fetches the data, places it onto `RDATA` along with an `OKAY` status on `RRESP`, and drives `RVALID` High. On the rising edge of Cycle 4, the Master asserts `RREADY`, completing the handshake and successfully latching the data.

## Response Codes (`BRESP` and `RRESP`)

The AXI4-Lite protocol handles error reporting through two-bit status buses: **`BRESP`** for write transactions and **`RRESP`** for read transactions. These signals are driven exclusively by the Slave to inform the Master of the success or failure of an executed transaction.

### Response Code Decoding Matrix

The master must decode the binary values on `BRESP` or `RRESP` at the precise clock edge when the respective `VALID` and `READY` handshake occurs.

|**Binary Value**|**Status Mnemonic**|**Definition**|**Hardware Behavior / Handling**|
|---|---|---|---|
|**`2'b00`**|**OKAY**|Normal Access Success|Indicates that the transaction was successfully decoded and executed by the slave peripheral.|
|**`2'b01`**|**EXOKAY**|Exclusive Access Success|**Not Supported in AXI4-Lite.** Exclusive or atomic accesses are disabled. An AXI4-Lite slave must never return this value.|
|**`2'b10`**|**SLVERR**|Slave Error|The address was valid and mapped to the slave, but the slave encountered a failure condition (e.g., trying to write to a read-only register, data timeout, or unaligned access).|
|**`2'b11`**|**DECERR**|Decode Error|Interconnect routing failure. Typically generated by a system-level bridge or default slave when the master attempts to access an unmapped or nonexistent address space.|

### Protocol Rules for Responses

- **Stabilization:** The slave must ensure that the data on `BRESP` or `RRESP` remains perfectly stable and valid while its corresponding response handshake is pending (`BVALID` or `RVALID` is High).
- **Reset Default:** During an active system reset (`ARESETn` is Low), the internal state machine tracking responses must clear, and the response signals are treated as invalid until a new transaction sequence completes.

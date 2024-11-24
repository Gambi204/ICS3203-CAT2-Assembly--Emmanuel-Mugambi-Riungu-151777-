### **Project Title**: Assembly Programming - Water Monitoring and Control Systems

---

### **Project Overview**

This project contains a collection of four assembly language programs, each demonstrating fundamental and advanced concepts in assembly programming:

1. **Task 1: Control Flow and Conditional Logic**  
   - **Purpose**: Classifies a user-input number as "POSITIVE," "NEGATIVE," or "ZERO" using conditional and unconditional jumps.  
   - **Highlights**: Efficient branching and control flow.

2. **Task 2: Array Manipulation with Looping and Reversal**  
   - **Purpose**: Reads an array of integers, reverses it in place, and outputs the reversed array.  
   - **Highlights**: Demonstrates in-place array reversal using loops and direct memory access.

3. **Task 3: Modular Factorial Calculation**  
   - **Purpose**: Computes the factorial of a user-input number using a subroutine.  
   - **Highlights**: Emphasizes modular programming and stack-based register preservation.

4. **Task 4: Data Monitoring and Control Using Port-Based Simulation**  
   - **Purpose**: Simulates a water level sensor that triggers a motor or alarm based on the sensor value.  
   - **Highlights**: Demonstrates control logic and simulation of hardware components using memory locations.

---

### **Instructions for Compiling and Running**

#### **General Requirements**
- Ensure a 32-bit assembly development environment is available.
- Install the necessary tools, such as:
  - `nasm` for assembling the code.
  - `ld` for linking.

#### **Steps to Compile and Run Each Task**

1. **Compile the Code**:
   ```bash
   nasm -f elf32 taskX.asm -o taskX.o
   ```
   Replace `taskX` with the specific task file name (e.g., `task1` for Task 1).

2. **Link the Code**:
   ```bash
   ld -m elf_i386 taskX.o -o taskX
   ```

3. **Run the Program**:
   ```bash
   ./taskX
   ```

---

### **Insights and Challenges**

#### **Task 1**: Control Flow and Conditional Logic  
- **Insights**:  
   The use of both conditional (`jz`, `jg`, `jl`) and unconditional (`jmp`) jumps allowed for a clear and concise classification of the input.  
- **Challenges**:  
   Debugging the branching logic to ensure all edge cases (e.g., zero input) were handled correctly.

#### **Task 2**: Array Manipulation with Looping and Reversal  
- **Insights**:  
   Demonstrated efficient memory usage by reversing the array in place without additional memory allocation.  
- **Challenges**:  
   Handling segmentation faults caused by incorrect pointer arithmetic and ensuring proper stack alignment for system calls.

#### **Task 3**: Modular Factorial Calculation  
- **Insights**:  
   Showcased the importance of modular design by using a subroutine for factorial calculation and proper stack-based register preservation.  
- **Challenges**:  
   Debugging input parsing to ensure only valid integers within the correct range (0-12) were processed to avoid integer overflow.

#### **Task 4**: Data Monitoring and Control Using Port-Based Simulation  
- **Insights**:  
   Provided a simulation of real-world hardware control systems using memory locations to represent ports for sensor inputs and motor/alarm statuses.  
- **Challenges**:  
   Ensuring that the control flow responded correctly to the sensor input and outputted appropriate actions for all edge cases.

---

### **GitHub Description**

**Assembly Programming - Water Monitoring and Control Systems**

This repository contains a series of assembly language programs demonstrating control flow, array manipulation, modular programming, and hardware simulation. The tasks include:
- Classifying numbers.
- Manipulating arrays.
- Calculating factorials.
- Simulating a water-level monitoring and control system.

These programs are designed to showcase advanced assembly techniques such as stack management, register preservation, and memory-based hardware simulation. The project is an excellent resource for learning practical assembly language programming concepts.

---

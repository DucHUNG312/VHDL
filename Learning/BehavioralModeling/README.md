#### Wait statement is used to hold the system for certain time duration. It can be used in three different ways as shown below:

- wait until : It is synthesizable statement and holds the system until the defined condition is met e.g. ‘’wait until clk = ‘1’‘’ will hold the system until clk is ‘1’.
- wait on : It is synthesizable statement and holds the system until the defined signal is changed e.g. ‘wait on clk’ will hold the system until clk changes it’s value i.e. ‘0’ to ‘1’ or vice-versa.
- wait for : It is not synthesizable and holds the system for the defined timed e.g. ‘wait for 20ns’ will hold the system for 20 ns.

# Interacting with python
**Under construction.**

- requests.metta is a simple wrapper around python requests module, enabling you to interact with external API's
- fs.metta attempts to make IO streams accessible in MeTTa. You can read n bytes from a stream using (read n). 

**Pending questions:**
- it seems like imports of atoms that use the *bind!* operator don't work (try importing defaults.metta)
- A while loop is added in fs.metta, but there is something wrong with the implementation. Currently, it gets incrementally slower...

To implement:
- (untill $value $do) operator. (currently I can detect EOS token in while loop, but not able to break out of it.)

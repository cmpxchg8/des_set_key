/**
 *  The MIT License:
 *
 *  Copyright (c) 2005, 2008 Kevin Devine
 *
 *  Permission is hereby granted,  free of charge,  to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"),  to deal
 *  in the Software without restriction,  including without limitation the rights
 *  to use,  copy,  modify,  merge,  publish,  distribute,  sublicense,  and/or sell
 *  copies of the Software,  and to permit persons to whom the Software is
 *  furnished to do so,  subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR
 *  IMPLIED,  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
 *  LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include <openssl/des.h>
     
void dump_hash (const char str[], uint8_t hash[]) 
{      
  uint8_t *p;
  printf ("\n  %-18s : ", str);
  for (p = hash; (p - hash) < 8; p++) {
    printf ("%.2X",*p);
  }
}

int main (int argc, char *argv[])
{
  uint32_t i, j;
  DES_cblock deskey;
  DES_key_schedule ks1, ks2;
  uint8_t hash1[8], hash2[8];
  
  uint32_t test_key[8], plaintext[8];

  puts ("\n  Precomputed DES Key Schedules"
        "\n  Copyright (c) 2006, 2008 Kevin Devine\n");
        
  srand (time(0));
  
  /* set key data */
  test_key[0] = rand ();
  test_key[1] = rand ();

  /* set plaintext */
  plaintext[0] = rand ();
  plaintext[1] = rand ();

  /* use the regular DES_set_key function first */
  DES_set_key ((DES_cblock*)&test_key, &ks1);
  DES_ecb_encrypt ((DES_cblock*)&plaintext, &hash1, &ks1, DES_ENCRYPT);
  dump_hash ("DES_set_key()", hash1);

  /* now use the routine with precomputed schedules */
  init_subkeys ();  // only required once
  sse2_DES_set_key ((DES_cblock*)&test_key, &ks2);
  DES_ecb_encrypt ((DES_cblock*)&plaintext, &hash2, &ks2, DES_ENCRYPT);
  dump_hash ("sse2_DES_set_key()", hash2);

  printf ("\n\n  Results %s match.\n", 
      memcmp (hash1, hash2, 8) == 0 ? "" : "do not");
  return 0;
}

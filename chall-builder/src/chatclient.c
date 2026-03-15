#include <stdio.h>
#include <string.h>

char key[] = "dev_secret_key";
char message[] = "inseclab{memory_leaks_are_dangerous}";

void encrypt(char *data, int len) {
    int keylen = strlen(key);
    for (int i = 0; i < len; i++) {
        data[i] ^= key[i % keylen];
    }
}

int main() {
    encrypt(message, strlen(message));
    printf("Encrypted message sent!\n");
    getchar(); // keep program running
    return 0;
}

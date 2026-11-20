/*
实现 Trie（前缀树）
支持 insert/search/startsWith。
*/

#include <iostream>
#include <string>

using namespace std;

class Trie {
public:
    Trie() : end(false) { for (int i = 0; i < 26; ++i) next[i] = nullptr; }

    void insert(string word) {
        Trie* t = this;
        for (char c : word) {
            int i = c - 'a';
            if (!t->next[i]) t->next[i] = new Trie();
            t = t->next[i];
        }
        t->end = true;
    }

    bool search(string word) {
        Trie* t = find(word);
        return t && t->end;
    }

    bool startsWith(string prefix) { return find(prefix) != nullptr; }

private:
    Trie* find(const string& s) {
        Trie* t = this;
        for (char c : s) {
            int i = c - 'a';
            if (!t->next[i]) return nullptr;
            t = t->next[i];
        }
        return t;
    }
    Trie* next[26];
    bool end;
};

int main() {
    Trie t;
    t.insert("apple");
    cout << t.search("apple") << endl;     // 1
    cout << t.startsWith("app") << endl;   // 1
    cout << t.search("app") << endl;       // 0
    return 0;
}

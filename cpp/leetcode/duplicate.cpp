/*
数组中重复的数字
*/
class Solution {
public:
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param numbers int整型vector 
     * @return int整型
     */
    int duplicate(vector<int>& numbers) {
        int len=numbers.size();
        for (int i=0; i<len; i++)
        {
            for(int j=i+1; j<len; j++)
            {
                if(numbers[i]==numbers[j])
                    return numbers[i];
            }
        }
        return -1;
    }
};

// 方法2: set, map, 唯一性
 int duplicate(vector<int>& numbers) {
        // write code here
        set<int> n_set;
        for(auto t:numbers){
            if(n_set.count(t)) return t;
            n_set.insert(t);
        }
        return -1;
    }

int duplicate(vector<int>& numbers) {
        // write code here
        map<int,int> list;
        for(int i=0;i<numbers.size();i++)
        {
            if(list[numbers[i]]!=-1)list[numbers[i]]=-1;
            else return numbers[i];
        }
        return -1;
    }
// 方法3：排序
int duplicate(vector<int>& numbers) {
        // write code here
      sort(numbers.begin(),numbers.end());
      vector<int>::iterator it=adjacent_find(numbers.begin(),numbers.end());
      if(it==numbers.end()){
          return -1;
      }
      else{
          return *it;
      }
    }
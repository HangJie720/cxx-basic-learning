/*
旋转数组的最小数字
*/
class Solution {
public:
    int minNumberInRotateArray(vector<int> rotateArray) {
        int left = 0, right = rotateArray.size() - 1;
        while(left < right)
        {
            int mid = left + (right - left) / 2;
            if(rotateArray[mid] > rotateArray[right])
                left = mid + 1;
            else if(rotateArray[mid] < rotateArray[right])
                right = mid;
            else
                --right;
        }
        return rotateArray[right];
    }
};
方法2：
class Solution {
public:
    int minNumberInRotateArray(vector<int> arr) {
        //假设一个数组的最小值为数组第一个数字
        int min=arr[0];
        //进行遍历数组，求出最小值
        for(int i=1;i<arr.size();i++)
            if(arr[i]<min)
            min=arr[i];
              return min;
         
    }
};


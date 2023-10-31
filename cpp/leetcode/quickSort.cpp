#include <iostream>  
#include <vector>  
  
using namespace std;  
  
int partition(vector<int>& nums, int left, int right) {  
    int pivot = nums[right];  // 选择最后一个元素作为枢轴  
    int i = left - 1;  // i 表示小于等于 pivot 的元素的最右边位置  
    for (int j = left; j < right; j++) {  
        if (nums[j] <= pivot) {  
            i++;  
            swap(nums[i], nums[j]);  // 将小于等于 pivot 的元素交换到左边  
        }  
    }  
    swap(nums[i+1], nums[right]);  // 将 pivot 放到分界点位置  
    return i+1;  
}  
  
void quickSort(vector<int>& nums, int left, int right) {  
    if (left < right) {  
        int p = partition(nums, left, right);  // 分区并得到分界点位置  
        quickSort(nums, left, p-1);  // 递归处理左半部分  
        quickSort(nums, p+1, right);  // 递归处理右半部分  
    }  
}  
  
int main() {  
    vector<int> nums = {5, 3, 8, 4, 2, 7, 1, 6};  
    quickSort(nums, 0, nums.size()-1);  
    for (auto num : nums) {  
        cout << num << " ";  
    }  
    cout << endl;  
    return 0;  
}
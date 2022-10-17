//
//  IIRFilter.hpp
//  AudioDemo
//
//  Created by zz on 2022/10/13.
//

#ifndef IIRFilter_hpp
#define IIRFilter_hpp

#define IIR_MAX_N 128

#include <stdio.h>
#include <list>
#include <iostream>

class IIRFilter {
public:
    IIRFilter(int n, double* cofficient_b, double* cofficient_a) : N(n)
    {
        memset(b, 0, sizeof(b));
        memset(a, 0, sizeof(a));
    
        memcpy(a, cofficient_a, sizeof(double)*n);
        memcpy(b, cofficient_b, sizeof(double)*n);
        
        for (int i = 0; i < n; ++i)
            x.push_back(0);
        
        // 由差分方程系数可知 y缓存比x少1
        for (int i = 0; i < n-1; ++i)
            y.push_back(0);
    }
    
    void process(double* input, double* output, int samples)
    {
        for (int i = 0; i < samples; ++i)
        {
            x.push_back(input[i]);
            x.pop_front();
            
            double bx = 0;
            int k = 0;
            for (auto it = x.rbegin(); it != x.rend(); ++it)
            {
                assert(k < N);
                double tmp_x = *it;
                bx += (b[k] * tmp_x);
                ++k;
            }
//            std::cout << "i : " << i << "  bx : " << bx << std::endl;
            
            double ay = 0;
            k = 1;
            for (auto it = y.rbegin(); it != y.rend(); ++it)
            {
                assert(k < N);
                //yn = y[n-k]*ak  k从1开始
                double tmp_y = *it;
                ay += (a[k] * tmp_y);
                ++k;
            }
            
//            std::cout << "i : " << i << "  ay : " << ay << std::endl;
            output[i] = bx-ay;
//            std::cout << "i : " << i << "  output : " << output[i] << std::endl;
//            if (output[i] > 1.0) output[i] = 1.0;
//            else if (output[i] < -1.0) output[i] = -1.0;
            
//            assert(output[i] > -1.0 && output[i] < 1.0);
            y.push_back(output[i]);
            y.pop_front();
        }
        
        y;
    }
    
private:
    int N;
    double b[IIR_MAX_N], a[IIR_MAX_N]; // 差分方程系数
    std::list<double> x, y; // 保存一定数据
};
#endif /* IIRFilter_hpp */

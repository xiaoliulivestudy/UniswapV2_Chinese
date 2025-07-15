# Python code checking:

# How swap and arbitrage in uniswapV2 work(error)

showing how this formula comes from

1. <https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol#L43>
2. <https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2LiquidityMathLibrary.sol#L17>

ua: reserveA         ub: reserveB

sa: truePriceTokenA  sb: truePriceTokenB

x: amountIn          y: amountOut

```python
>>> from sympy import *
>>> ua, ub, sa, sb, x, y, r_in, r_out, d = symbols('ua ub sa sb x y in, out, d')
>>> init_printing(use_unicode=True)
>>> k_before_swap = ua * ub
>>> k_after_swap = (ua+x)*(ub-y)
>>> solve(Eq(k_before_swap, k_after_swap), y)
⎡ ub⋅x ⎤
⎢──────⎥
⎣ua + x⎦
>>> true_price = sa/sb
>>> price_after_arbitrage = (ua + x) / (ub - (x*ub)/(ua+x))
>>> price_after_arbitrage
    ua + x   
─────────────
   ub⋅x      
- ────── + ub
  ua + x     
>>> price_after_arbitrage.subs({x: 0.997*x})
    ua + 0.997⋅x   
───────────────────
   0.997⋅ub⋅x      
- ──────────── + ub
  ua + 0.997⋅x     
>>> solve(Eq(true_price, price_after_arbitrage),x)
⎡        _____________          _____________⎤
⎢      ╲╱ sa⋅sb⋅ua⋅ub         ╲╱ sa⋅sb⋅ua⋅ub ⎥
⎢-ua - ───────────────, -ua + ───────────────⎥
⎣             sb                     sb      ⎦
>>> price_after_arbitrage=price_after_arbitrage.subs({x: 0.997*x})
>>> price_after_arbitrage
    ua + 0.997⋅x   
───────────────────
   0.997⋅ub⋅x      
- ──────────── + ub
  ua + 0.997⋅x     
>>> solve(Eq(true_price, price_after_arbitrage),x)
⎡                 ⎛           _____________⎞                   ⎛           ___
⎢1.00300902708124⋅⎝-sb⋅ua - ╲╱ sa⋅sb⋅ua⋅ub ⎠  1.00300902708124⋅⎝-sb⋅ua + ╲╱ sa
⎢───────────────────────────────────────────, ────────────────────────────────
⎣                     sb                                           sb         

__________⎞⎤
⋅sb⋅ua⋅ub ⎠⎥
───────────⎥
           ⎦
>>> solve(Eq(true_price, price_after_arbitrage),x)
⎡                 ⎛           _____________⎞                   ⎛           ___
⎢1.00300902708124⋅⎝-sb⋅ua - ╲╱ sa⋅sb⋅ua⋅ub ⎠  1.00300902708124⋅⎝-sb⋅ua + ╲╱ sa
⎢───────────────────────────────────────────, ────────────────────────────────
⎣                     sb                                           sb         

__________⎞⎤
⋅sb⋅ua⋅ub ⎠⎥
───────────⎥
           ⎦
>>> solve(Eq(true_price, price_after_arbitrage),x)
⎡                 ⎛           _____________⎞                   ⎛           ___
⎢1.00300902708124⋅⎝-sb⋅ua - ╲╱ sa⋅sb⋅ua⋅ub ⎠  1.00300902708124⋅⎝-sb⋅ua + ╲╱ sa
⎢───────────────────────────────────────────, ────────────────────────────────
⎣                     sb                                           sb         

__________⎞⎤
⋅sb⋅ua⋅ub ⎠⎥
───────────⎥
           ⎦
>>> get_amount_in = (1000 * r_in * y)/(997*(r_out - y))
>>> get_amount_out = (997 * r_out * x)/(1000 * r_in + 997 * x)
>>> profit = get_amount_out.subs({x: d, r_in: ua, r_out: ub}) - get_amount_in.subs({y: d, r_in: sb, r_out: sa})
>>> solve(Eq(diff(profit, d), 0), d)[1]
                                         _____________             ___________
-1000⋅sa⋅sb⋅ua - 997⋅sa⋅ua⋅ub + 997⋅sa⋅╲╱ sa⋅sb⋅ua⋅ub  + 1000⋅ua⋅╲╱ sa⋅sb⋅ua⋅u
──────────────────────────────────────────────────────────────────────────────
                             997⋅sa⋅sb - 997⋅ua⋅ub                            

__
b 
──
  
>>> profit2 = sa/sb*x-(0.997*ub*x)/(ua+0.997*x)
>>> solve(Eq(diff(profit2, x), 0), x)[1]
                    ⎛                                   _____________⎞
0.00100300902708124⋅⎝-1000.0⋅sa⋅ua + 998.498873309329⋅╲╱ sa⋅sb⋅ua⋅ub ⎠
──────────────────────────────────────────────────────────────────────
                                  sa                                  
>>> profit2 = sa/sb*x-(d*ub*x)/(ua+d*x)
>>> solve(Eq(diff(profit2, x), 0), x)[1]
              ________________
             ╱  3             
-d⋅sa⋅ua + ╲╱  d ⋅sa⋅sb⋅ua⋅ub 
──────────────────────────────
             2                
            d ⋅sa             
>>> price_after_arbitrage = (ua + x) / (ub - (d*x*ub)/(ua+d*x))
>>> price_after_arbitrage
     ua + x    
───────────────
   d⋅ub⋅x      
- ──────── + ub
  d⋅x + ua     
>>> solve(Eq(true_price, price_after_arbitrage),x)
⎡                    __________________________________________________       
⎢                   ╱       ⎛ 2                                      ⎞        
⎢-sb⋅ua⋅(d + 1) - ╲╱  sb⋅ua⋅⎝d ⋅sb⋅ua + 4⋅d⋅sa⋅ub - 2⋅d⋅sb⋅ua + sb⋅ua⎠   -sb⋅u
⎢──────────────────────────────────────────────────────────────────────, ─────
⎣                                2⋅d⋅sb                                       

               __________________________________________________⎤
              ╱       ⎛ 2                                      ⎞ ⎥
a⋅(d + 1) + ╲╱  sb⋅ua⋅⎝d ⋅sb⋅ua + 4⋅d⋅sa⋅ub - 2⋅d⋅sb⋅ua + sb⋅ua⎠ ⎥
─────────────────────────────────────────────────────────────────⎥
                           2⋅d⋅sb                                ⎦
>>> true_price
sa
──
sb

```



**ref:**

https://gist.github.com/wuwe1/8a84facb2fcf87029953430dc78b38a5



他的公式忽略了手续费

dx=0.997x

ua+dx/(ub-dy)

应该是:

(ua+x)/(ub-dy)
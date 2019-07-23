module Augmentation.SymPinch
    (pinch
    ,pinchMap
    ) where

import Algebra.Symbolic
import Algebra.SymDGA
import Augmentation.Braid
import Augmentation.Disks
import Braid

import Data.List
import Data.Maybe
import Data.Either
import Control.Monad

remove_unused :: AugBraid -> AugBraid
remove_unused (AugBraid w ws) = case (unusedh w ws 0) of (w',ws') -> AugBraid w ws'

unusedh :: Int -> [Either (Int,Char,Char) Int] -> Int -> (Int, [Either (Int,Char,Char) Int])
unusedh w ws s
    | s == w = (w,ws)
    | (and $ map (\s' -> not $ elem s' $ rights ws) [s,s+1]) = (min wm (w-1), map (\x ->
        case x of (Left (i,c,c')) -> Left (if i == s then 0 else if i > s then i-1 else i,c,c')
                  (Right i) -> Right (if i > s then i-1 else i)) wms)
    | otherwise = unusedh w ws (s+1)
    where (wm,wms) = unusedh (w-1) ws s

pinch :: Int -> AugBraid -> Maybe AugBraid
pinch x b = (Just . remove_unused) =<< (pinchh x (get_word b) (get_width b) (newChars x b))

pinchh :: Int -> [Either (Int,Char,Char) Int] -> Int -> Maybe (Char,Char) -> Maybe AugBraid
pinchh _ [] _ _ = Nothing
pinchh x ((Left (i,c,cinv)):cs) w t = (\b -> Just $ AugBraid w $ (Left (i,c,cinv)):(get_word b)) =<< (pinchh x cs w t)
pinchh 0 ((Right i):cs) w t = (\(c,cinv) -> return $ AugBraid w $ (Left (i,c,cinv)):cs) =<< t
pinchh x ((Right i):cs) w t = (\b -> Just $ AugBraid w $ (Right i):(get_word b)) =<< (pinchh (x-1) cs w t)

ithcross :: Int -> AugBraid -> Maybe Char
ithcross i b = crossh i (get_word b) (algebra_footprint b)

crossh _ [] _ = Nothing
--crossh _ [] _ = '\1'
crossh i w f = if (isRight (head w))
                then if (i == 0) then Just $ fst $ head f
                                 else crossh (i-1) (tail w) (tail f)
                else crossh i (tail w) (tail $ tail f)

newChars :: Int -> AugBraid -> Maybe (Char,Char)
newChars x b = charh x (get_word b) 460 --4607

charh _ [] _ = Nothing
charh 0 ((Right _):_) t = Just (toEnum (t+1), toEnum (t+2))
charh x ((Right _):cs) t = charh (x-1) cs (t+2)
charh x ((Left _):cs) t = charh x cs (t+2)
--charh x ((Left (_z,c,cinv)):cs) t = charh x cs ((+) 1 $ foldr max (t+1) [fromEnum c,fromEnum cinv])

pinchMap :: Int -> AugBraid -> Maybe (DGA_Map, AugBraid)
pinchMap _ (AugBraid 0 _) = Just (Map [], AugBraid 0 [])
pinchMap _ (AugBraid _ []) = pinchMap 0 (AugBraid 0 [])
pinchMap x b@(AugBraid _ w) = do
    { let chars = algebra_footprint b
    ; let foot' = zipWith (\c x -> (c,isCross b x)) chars [0..]
    ; change <- ithcross x b
    ; (c,cinv) <- newChars x b
    ; let ccinv = (cinv,c):(map (\(_,c',cinv') -> (cinv',c')) $ lefts w)
    ; let cinvs = map fst ccinv
    ; let disks = map (\((c0,i),k) -> (++) [[c0]] $ map (\d -> cinv:(neg d)) $ augmentationDisks b change c0) foot'
    ; let cnegs = catMaybes $ map (\((c0,i),k) -> if c0 == change
            then Just $ (c0,[[c]])
            else if i == 0
                then Nothing
                else if k
                    then Just $ (c0,(++) [[c0]] $ map (\d -> cinv:(neg d)) $ augmentationDisks b change c0)
                    else Nothing -- Just (c0,[[c0]])
            ) foot'
    ; let cexps = map (\(c,s) -> (c,sum $ map (\t' -> product $ map (\t -> if t `elem` cinvs then (recip $ maybe Fail Var $ lookup t ccinv) else Var t) t') s)) $ filter (\(_,s) -> s /= []) cnegs
    ; let dmap = Map cexps
    ; b' <- pinch x b
    ; return $ (dmap, b')
    }
module Augmentation.SymGraph
    (pinchGraph
    ,getUniques
    ,numAugmentations
    ) where

import Algebra.Symbolic
import Algebra.SymDGA
import Augmentation.Disks
import Augmentation.Braid
import Augmentation.SymPinch
import Braid
import Libs.Graph

import Braid.GenBraid

import Data.List
import Data.Maybe
import Data.Either
import Control.Monad

import Debug.Trace

nullGraph = Leaf [(Map [],AugBraid 0 [])]

pinchgraphh :: [(DGA_Map,AugBraid)] -> Int -> LevelGraph (DGA_Map,AugBraid)
pinchgraphh last 1 = trace ("LeafSize: " ++ (show $ length last)) $ Leaf last
pinchgraphh last i = let thisnext = map (\(m1,b1) ->
                            let preforest = catMaybes $ map (\y -> pinchMap (y-1) b1) [1..(length $ get_word $ toStdBraid b1)]
                                forest = map (\(m2,b2) -> (composeMaps m2 m1,b2)) preforest
                             in ((m1,b1),forest)
                            ) last
                         next = nub $ concat $ (map snd thisnext)
                         this = nub $ map (\(a,as) -> (a, catMaybes $ map (\s -> getnum next s) as)) thisnext
                      in trace ("LevelSize: " ++ show (length this)) $ Level this $ pinchgraphh next $ i-1

pinchGraph :: StdBraid -> LevelGraph (DGA_Map, AugBraid)
pinchGraph (StdBraid 0 _) = nullGraph
pinchGraph (StdBraid _ []) = nullGraph
pinchGraph b = let l = map (\x -> x-1) $ [1..(length $ get_word b)]
                   nodes = catMaybes $ map (\x -> pinchMap x $ fromStdBraid b) l
                in Level [((Map [],fromStdBraid b),l)] $ pinchgraphh nodes (length l)

getnum :: Eq a => [a] -> a -> Maybe Int
getnum [] _ = Nothing
getnum (a:as) t = if a == t then Just 1 else (return . (+) 1) =<< (getnum as t)

getUniques :: StdBraid -> DGA_Map -> [[Expr Double]]
getUniques b rels = nub $ map (\(m,b') -> (map (applyDGAMap m) $ map (\(c,_) -> Var c) $ algebra_footprint b)) $ map (\(m,b') -> (composeMaps rels m,b')) $ leaves $ pinchGraph b

numAugmentations :: StdBraid -> DGA_Map -> Integer
numAugmentations b rel = (\n -> traceShow n n) $ genericLength $ getUniques b rel
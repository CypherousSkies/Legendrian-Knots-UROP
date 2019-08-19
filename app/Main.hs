module Main
    (main
    ) where

import qualified Conjecture as C
import Libs.Graph
import Augmentation.Braid
import Augmentation
import Algebra
import Braid
import Control.Monad.Random
import qualified System.IO
import Data.List
import Data.Maybe
import Data.Tree
import Data.Functor.Identity

b0 :: AugBraid
b0 = genTorusBraid 3 2
alph = map fst $ algebra_footprint b0

b1 :: StdBraid
b1 = genTorusBraid 3 2

dothing = mapM_ print $ fromJust $ relations b1

showlh [] = "]"
showlh [a] = a ++ "]"
showlh (a:as) = a ++ "," ++ showlh as

fac 0 = 1
fac n = n * (fac $ n-1)
catalan  n = div (fac $ 2*n) $ (fac $ n+1) * (fac n)
testnums m n = 0.5*((fac $ 2 * m) * (fac $ 2 * n))/((fac $ m+n)*(fac m)*(fac n))
numAug m n = numAugmentations $ genTorusBraid m n

{-
out = outh [2..5] 3
outh::[Int]->Int->IO ()
outh [] _ = ""
outh (x:xs) m = ((++) (show x ++ ": , ") $ foldr (\s ss -> (show s) ++ ", " ++ ss) "\n" $ map (numAug x) [1..m]) ++ (outh xs m)
-}
file = "data/NumAugs.csv"

putInFile :: [Int] -> Int -> IO ()
putInFile (i:is) n = do { let ks = map (getAugs . genTorusBraid i) [1..n]
                        ; mapM_ (\k -> (print $ maybe 0 length k) >> (appendFile file $ show (maybe 0 length k) ++ ",")) ks
                        ; appendFile file "\n"
                        ; putInFile is n
                        } 

skrubAugs b@(StdBraid _ w) = do
                            { let dim = length w
                            ; let chars = map sChar [1..dim]
                            --; let rel = relations' b 
                            ; let alph = map fst $ algebra_footprint b
                            ; let lg = pinchGraph b
                            ; ls <- mapM (\(DGA_Map l,_) -> mapM (\(c,a) -> (represent chars a) >>= (\r -> Just (c,r))) l) $ leaves lg
                            ; let augs = map (\l -> Aug b $ (\l -> filter (\v -> 1 == ((length $ filter (==v) l) `mod` 2)) $ nub l) $ map (\(c,vs) -> (c,{-map (\v -> rel #> v)-} vs)) l) ls
                            ; return augs
                            }

numeach :: LevelGraph a -> [Int]
numeach (Leaf as) = [length as]
numeach (Level ans lg) = (length ans):(numeach lg)

main = do { print "Running"
          ; C.main
          --; let u = fromJust $ getAugs $ genTorusBraid 3 2
          --; let v = fromJust $ getAugs $ genTorusBraid 2 3
          --; mapM_ print u
          --; print $ length u
          --; mapM_ print v
          --; print $ length v
          ; appendFile file "\n"
          --; print $ numAugs $ genTorusBraid 3 3
          --; print $ numAugs $ genTorusBraid 3 2
          --; print $ numAugs $ genTorusBraid 3 3
          --; appendFile "Data.csv" $ show augs
          ; putInFile [2..5] 7
          --; mapM_ (fileperms 2) [1..5]
          --; mapM_ (fileperms 3) [1..5]
          --; mapM_ (fileperms 4) [1..3]
          --; mapM_ (fileperms 5) [1..3]
          -- putInFile [2..5] 5
          --; putStrLn out
          --; writeFile "data.csv" out
          --; putStrLn "Test Braid and leaves"
          --; putStrLn thing
          --; uniques
          --; putStrLn "Test Cases"
          --; putStrLn "123"
          --; mapM_ putStrLn $ map (\x -> (show x) ++ ":" ++ show (applyDGAMap m123 x) ++ "\t\t\t" ++ show (applyDGAMap m123' x)) alph
          --; putStrLn "132"
          --; mapM_ putStrLn $ map (\x -> (show x) ++ ":" ++ show (applyDGAMap m132 x) ++ "\t\t\t" ++ show (applyDGAMap m132' x)) alph
          --; putStrLn "312"
          --; mapM_ putStrLn $ map (\x -> (show x) ++ ":" ++ show (applyDGAMap m312 x) ++ "\t\t\t" ++ show (applyDGAMap m312' x)) alph
          --; putStrLn "213"
          --; mapM_ putStrLn $ map (\x -> (show x) ++ ":" ++ show (applyDGAMap m213 x) ++ "\t\t\t" ++ show (applyDGAMap m213' x)) alph
          --; putStrLn "231"
          --; mapM_ putStrLn $ map (\x -> (show x) ++ ":" ++ show (applyDGAMap m231 x) ++ "\t\t\t" ++ show (applyDGAMap m231' x)) alph
          --; putStrLn "321"
          --; mapM_ putStrLn $ map (\x -> (show x) ++ ":" ++ show (applyDGAMap m321 x) ++ "\t\t\t" ++ show (applyDGAMap m321' x)) alph
          --; print b0
          --; putStrLn "Bad Guess:"
          --; print lefnum
          --; putStrLn "Worse Guess:"
          --; print numbers
          --; leafyBois
          --; putStrLn "2,n Experiment"
          --; let n = 10
          --; let aug = map (numAug 2) [1..10]
          --; let cat = map catalan [1..10] 
          --; putStrLn "Upper Bound"
          --; print $ map fac [1..10]
          --; putStrLn "Program"
          --; print aug 
          --; putStrLn "Target"
          --; print cat 
          --; putStrLn "Same?"
          --; print $ aug == cat
          --; putStrLn "Test Cases"
          --; print b1
          --; mapM_ (\c -> putStrLn $ (show $ map1' c) ++ "\t" ++ (show $ map1p c)) alph
          --; print b2
          --; mapM_ (\c -> putStrLn $ (show $ map2' c) ++ "\t" ++ (show $ map2p c)) alph
          --; print b3
          --; mapM_ (\c -> putStrLn $ (show $ map3' c) ++ "\t" ++ (show $ map3p c)) alph
          }
{-
main = do { System.IO.hSetEncoding System.IO.stdout System.IO.utf8
          ; putStrLn "Step 1"
          ; mapM_ (print . map1) alph
          ; putStrLn "Step 2"
          ; mapM_ (print . map2) alph
          ; putStrLn "Step 3"
          ; mapM_ (print . map3) alph
          ; putStrLn "Step 1"
          ; mapM_ (print . map1') alph
          ; putStrLn "Step 2"
          ; mapM_ (print . map2') alph
          ; putStrLn "Step 3"
          ; mapM_ (print . map3') alph
          }
-}
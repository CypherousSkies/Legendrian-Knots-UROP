module Algebra.FreeGroup
    (FreeGroup (Id,E)
    ,groupPlugIn
    ,toPseudoVector
    ) where

import Algebra.Group

infixl 5 :<>:

data FreeGroup = Id
        | E Char
        | FreeGroup :<>: FreeGroup
        | Recip FreeGroup

toPseudoVector :: FreeGroup -> Maybe [(Char,Int)]
toPseudoVector Id = Just []
toPseudoVector (E c) = Just [(c,1)]
toPseudoVector (Recip (E c)) = Just [(c,-1)]
toPseudoVector (a :<>: b) = do
                            { c1 <- toPseudoVector a
                            ; c2 <- toPseudoVector b
                            ; let f l1 l2 = if l1 == [] then l2 else if l2 == [] then l1 else
                                            if (fst $ head l1) `elem` (map fst l2)
                                                then f (tail l1) $ map (\(c,p) -> if c == (fst $ head l1) then (c,p+(snd $ head l1)) else (c,p)) l2
                                                else f (tail l1) $ (head l1):l2
                            ; return $ f c1 c2
                            }
toPseudoVector _ = Nothing

primEq :: FreeGroup -> FreeGroup -> Bool
primEq Id Id = True
primEq (E a) (E b) = a == b
primEq (a :<>: b) (c :<>: d) = (primEq a c) && (primEq b d)
primEq (Recip a) (Recip b) = primEq a b
primEq _ _ = False

invert' :: FreeGroup -> FreeGroup
invert' Id = Id
invert' (E c) = Recip (E c)
invert' (Recip a) = fullsimplify a
invert' (a :<>: b) = fullsimplify $ (invert b) :<>: (invert a)

simplify :: FreeGroup -> FreeGroup
simplify Id = Id
simplify (E c) = E c
simplify (Id :<>: b) = simplify b
simplify (a :<>: Id) = simplify a

simplify (a :<>: Recip b) | primEq a b = Id
simplify (Recip a :<>: b) | primEq a b = Id
simplify (a :<>: (Recip b :<>: c)) | primEq a b = simplify c
simplify (Recip a :<>: (b :<>: c)) | primEq a b = simplify c
simplify ((a :<>: b) :<>: Recip c) | primEq b c = simplify a
simplify ((a :<>: Recip b) :<>: c) | primEq b c = simplify a

simplify (Recip (Recip a)) = simplify a
simplify (Recip Id) = Id
simplify (Recip (a :<>: b)) = (simplify $ Recip b) :<>: (simplify $ Recip a)

simplify ((a :<>: b) :<>: c) = simplify $ a :<>: (simplify $ b :<>: c)

simplify (a :<>: b) = simplify a :<>: simplify b
simplify a = a

groupPlugIn :: Group b => (Char -> b) -> FreeGroup -> b
groupPlugIn f (E c) = f c
groupPlugIn f Id = mempty
groupPlugIn f (Recip g) = invert $ groupPlugIn f g
groupPlugIn f (a :<>: b) = (groupPlugIn f a) <> (groupPlugIn f b) 

fullsimplify :: FreeGroup -> FreeGroup
fullsimplify e = simp e Id
    where simp e l | primEq e l = e
                   | otherwise = simp (simplify e) e

instance Eq FreeGroup where
    Id == Id = True
    _ == Id = False
    Id == _ = False
    a == b = primEq Id $ a <> (invert b)
instance Show FreeGroup where
    show Id = "1"
    show (E c) = [c]
    show (a :<>: b) = show a ++ show b
    show (Recip a) = show a ++ "\8315\185"
instance Semigroup FreeGroup where
    a <> b = fullsimplify $ a :<>: b
instance Monoid FreeGroup where
    mempty = Id
instance Group FreeGroup where
    invert = invert'

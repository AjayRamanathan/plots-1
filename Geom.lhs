> module Geom where

> {-# LANGUAGE NoMonomorphismRestriction #-}

> import Diagrams.Coordinates
> import Diagrams.Prelude

> import Iso
> import DiagramUtils
> import Scales
> import Attributes

> data GeomPoint rowT b a = GeomPoint 
>     { pointGeomX     :: (Attributes.Attribute rowT Double,
>                          [rowT] -> Attributes.Attribute rowT Double -> AffineScale),
>       pointGeomY     :: (Attributes.Attribute rowT Double,
>                          [rowT] -> Attributes.Attribute rowT Double -> AffineScale),
>       pointGeomSize  :: Maybe (Attributes.Attribute rowT Double,
>                                [rowT] -> Attributes.Attribute rowT Double -> AffineScale),
>       pointGeomColor :: Maybe (Attributes.Attribute rowT b,
>                                [rowT] -> Attributes.Attribute rowT b -> DScale b (Colour a))
>     }

> splot :: GeomPoint rowT b Double -> [rowT] -> DC
> splot (GeomPoint px py mpsize mpcolor) rows = -- attr xscale yattr yscale sattr sscale cattr cscale) rows =
>     scatterplot where
>      shapeFun rows x = circle 0.01 # fc (color x) # lc white # lw 0.002
>          where color = case mpcolor of 
>                        Nothing -> const black
>                        Just _ -> ap (colorScaleFromPointGeom pcolor rows) . ap (attrFromGeomSpec pcolor)
>      scatterplot     = (view (p2 (0,0)) (r2 (1,1)) $ mconcat $ zipWith translated sizedShapes points) # translate ((-0.5) & (-0.5))
>      Just pcolor     = mpcolor
>      Just psize      = mpsize
>      x               = xyFromGeomSpec px rows
>      y               = xyFromGeomSpec py rows
>      size            = xyFromGeomSpec psize rows
>      xFun            = ap x    . ap (attrFromGeomSpec px)
>      yFun            = ap y    . ap (attrFromGeomSpec py)
>      sizeFun         = case mpsize of
>                        Nothing -> const 1
>                        Just _ -> ap size . ap (attrFromGeomSpec psize)
>      sizes           = map sizeFun rows
>      shapes          = map (shapeFun rows) rows
>      sizedShapes     = zipWith (\x y -> x # scale y) shapes sizes
>      points          = map (\pt -> (xFun pt, yFun pt)) rows

> colorScaleFromPointGeom :: (Attributes.Attribute rowT b,
>                             [rowT] -> Attributes.Attribute rowT b -> DScale b (Colour a)) -> [rowT] -> DScale b (Colour a)
> colorScaleFromPointGeom (attr, scale) rows    = scale rows attr

> xyFromGeomSpec :: (Attributes.Attribute rowT Double,
>                    [rowT] -> Attributes.Attribute rowT Double -> AffineScale) -> [rowT] -> AffineScale
> xyFromGeomSpec    (attr, scale) rows = scale rows attr

> attrFromGeomSpec (attr, _) = attr

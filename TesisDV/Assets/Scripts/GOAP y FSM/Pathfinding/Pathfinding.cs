using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Collections;

public class Pathfinding
{
    
    bool InSight(Vector3 start, Vector3 end)
    {
        //Vector3 dir = end - start;
        if(!Physics.Raycast(start, end - start, Vector3.Distance(start,end), GameVars.Values.GetWallLayerMask()))
        {
            return true;
        }
        else
        {
            return false; 
        }
    }

    
    
    float Heuristic(Vector3 a, Vector3 b)
    {
        return Vector3.Distance(a, b);
    }
}
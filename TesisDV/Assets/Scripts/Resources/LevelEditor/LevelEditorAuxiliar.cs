using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelEditorAuxiliar : MonoBehaviour
{
    public LevelManager lvm;
    public int selectedPoint = 0;

    private void OnDrawGizmos()
    {
        if (lvm != null && lvm.path != null)
        {
            for (int i = 0; i < lvm.path.Count; i++)
            {
                if (i + 1 < lvm.path.Count)
                {
                    Gizmos.DrawLine(lvm.path[i], lvm.path[i + 1]);
                }
                Gizmos.DrawWireCube(lvm.path[i], new Vector3(0.5f, 0.5f, 0.5f));
            }
        }
    }

    public void RemovePoint(int index)
    {
        if (index == 0 || index == lvm.path.Count - 1) return;
        if (lvm.path.Count < 3) return;
        lvm.path.RemoveAt(index);
        selectedPoint = index;
    }

    public void AddPoint(int index)
    {
        if (lvm.path == null) lvm.path = new List<Vector3>();
        lvm.path.Add(Vector3.zero);
        
        if (index == lvm.path.Count - 2)
        {
            lvm.path[index + 1] = new Vector3(lvm.path[index].x + 1f, 0f, 0f);
        }
        else
        {
            for (int i = lvm.path.Count - 2; i > index; i--)
            {
                lvm.path[i + 1] = lvm.path[i];
            }
            lvm.path[index + 1] = new Vector3((lvm.path[index].x + lvm.path[index + 2].x) / 2, (lvm.path[index].y + lvm.path[index + 2].y) / 2, (lvm.path[index].z + lvm.path[index + 2].z) / 2);
        }
        selectedPoint = index + 1;
    }
}

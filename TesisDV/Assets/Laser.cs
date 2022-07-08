using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : MonoBehaviour
{
    // Start is called before the first frame update
    private LineRenderer lr;
    public Transform startPosition;
    void Start()
    {
        lr = GetComponent<LineRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        lr.SetPosition(0, startPosition.position);
        RaycastHit hit;
        //if (Physics.Raycast(startPosition.position, startPosition.forward, out hit))
        if (Physics.Raycast(startPosition.position, startPosition.forward, out hit, 100f))
        {
            if (hit.collider)
            {
                lr.SetPosition(1, hit.point);
                if (hit.collider.isTrigger)
                    lr.SetPosition(1, startPosition.forward * 10);
            }
            else
                lr.SetPosition(1, startPosition.forward * 10);

        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowTrap : MonoBehaviour
{
    [SerializeField] private float _slowAmount;

    void OnTriggerEnter(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(_slowAmount);
        }
    }

    void OnTriggerExit(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(-_slowAmount);
        }
    }
}

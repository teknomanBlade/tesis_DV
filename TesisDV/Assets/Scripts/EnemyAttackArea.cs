using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAttackArea : MonoBehaviour
{
    [SerializeField]
    private Enemy _myOwner;
    [SerializeField] private int _damageAmount;

    void Start()
    {
        _myOwner = transform.parent.GetComponent<Enemy>();
    }

    void OnTriggerEnter(Collider other)
    {
        var player = other.GetComponent<Player>();

        if (player)
        {
            other.GetComponent<Player>().Damage(_damageAmount);   
        }
    }
}

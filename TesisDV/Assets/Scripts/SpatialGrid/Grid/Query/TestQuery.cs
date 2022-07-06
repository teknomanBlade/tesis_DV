using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System;

public class TestQuery : MonoBehaviour
{
    [SerializeField] SquareQuery squareQuery;
    
    void Awake()
    {
        squareQuery = GameObject.Find("Query").GetComponent<SquareQuery>();
    }

    public EnemyHealth GetClosestEnemy(Vector3 trapPosition)
    {
        transform.position = trapPosition;
        squareQuery.transform.position = trapPosition;

        EnemyHealth closestEnemy = null;
        float maxDistance = 1000f;

        var closestEnemyQuery = squareQuery.Query().Select(x => x as EnemyHealth);

        foreach (var enemy in closestEnemyQuery)
        {
            var distance = Vector3.Distance(trapPosition, enemy.transform.position);

            if (distance < maxDistance)
            {
                maxDistance = distance;
                closestEnemy = enemy;
            }
        }
        //Debug.Log(closestEnemy.gameObject.name);
        return closestEnemy;
    }

    
}

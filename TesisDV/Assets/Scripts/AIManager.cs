using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIManager : MonoBehaviour
{
    public List<Enemy> enemyList = new List<Enemy>();
    public GameObject currentTarget;
    private Dictionary<Enemy, GameObject> _enemiesPosition = new Dictionary<Enemy, GameObject>();
    private bool _isTargetSet;
    public static AIManager Instance;

    private void Awake()
    {
        Instance = this;
    }

    private void Update()
    {
        if(_isTargetSet)
        {
            CalculatePositions();
        }
       
    }

    private void CalculatePositions()
    {
        int positionsQty = enemyList.Count;
        float rotAngle = 360f / positionsQty;
        float rotAngleSum = 0f;
        int step = 0;
        foreach (var enemy in _enemiesPosition)
        {
            var temp = enemy.Value;

            temp.transform.SetParent(currentTarget.transform);
            temp.transform.localPosition = new Vector3((step + 1) * enemy.Key.protectDistance, 0, (step + 1)*enemy.Key.protectDistance);
            temp.transform.RotateAround(currentTarget.transform.position, Vector3.up, rotAngleSum + rotAngle);
            rotAngleSum += rotAngle;
        }
    }

    public Vector3 RequestPosition(Enemy enemy)
    {
        if (_enemiesPosition.ContainsKey(enemy))
        {
            Vector3 aux = _enemiesPosition[enemy].transform.position;
            
            return new Vector3(aux.x, 0f, aux.z);
        }
        else
        {
            Vector3 aux = currentTarget.transform.position;
            return new Vector3(aux.x, 0f, aux.z);
        }
            
    }

    public void RemoveEnemyFromList(Enemy enemy, bool hasCat)
    {
        enemyList.Remove(enemy);
        if(hasCat)
        {
            _isTargetSet = false;
            currentTarget = null;
        }
    }

    public void SetNewTarget(GameObject newTarget)
    {
        currentTarget = newTarget;
        _isTargetSet = true;
    }

    public void SubscribeEnemyForPosition(Enemy enemy)
    {
        if (!enemyList.Contains(enemy))
            enemyList.Add(enemy);
        if (!_enemiesPosition.ContainsKey(enemy))
            _enemiesPosition.Add(enemy, new GameObject("marker"));
    }
}

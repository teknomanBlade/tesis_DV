using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIManager : MonoBehaviour
{
    public List<Enemy> enemyList = new List<Enemy>();
    public List<GameObject> markers = new List<GameObject>();
    public GameObject currentTarget;
    private Dictionary<Enemy, GameObject> _enemiesPosition = new Dictionary<Enemy, GameObject>();
    [SerializeField] private bool _isTargetSet;
    private GameObject parent;
    public static AIManager Instance;

    private void Awake()
    {
        Instance = this;
    }

    void Start()
    {
        parent = GameObject.Find("MainGame");
    }

    private void Update()
    {
        //if(_isTargetSet)
        //{
            CalculatePositions();
        //}
    }

    private void CalculatePositions()
    {
        if(_isTargetSet)
        {
            int positionsQty = enemyList.Count;
            float rotAngle = 360f / positionsQty;
            float rotAngleSum = 0f;
            int step = 0;
            foreach (var enemy in _enemiesPosition)
            {
                var temp = enemy.Value;
                //if(temp != null)
                //{
                    temp.transform.SetParent(currentTarget.transform);
                    temp.transform.localPosition = new Vector3((step + 1) * enemy.Key.protectDistance, 0, (step + 1)*enemy.Key.protectDistance);
                    temp.transform.RotateAround(currentTarget.transform.position, Vector3.up, rotAngleSum + rotAngle);
                    rotAngleSum += rotAngle;
                //}
            }
        }
    }

    public Vector3 RequestPosition(Enemy enemy)
    {
        if (_enemiesPosition.ContainsKey(enemy))
        {
            /* Vector3 aux = _enemiesPosition[enemy].transform.position;
            return new Vector3(aux.x, 0f, aux.z); */
            return _enemiesPosition[enemy].transform.position;
        }
        else
        {
            Debug.Log("Esto existe?");
            Vector3 aux = currentTarget.transform.position;
            return new Vector3(aux.x, 0f, aux.z);
        }
    }

    public void RemoveEnemyFromList(Enemy enemy, bool hasCat)
    {
        _enemiesPosition.Remove(enemy);
        enemyList.Remove(enemy);
        if(hasCat)
        {
            _isTargetSet = false;
            currentTarget = null;

            foreach(GameObject marker in markers)
            {
                marker.transform.SetParent(parent.transform);
            } 
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
        {
            enemyList.Add(enemy);
        }
        if (!_enemiesPosition.ContainsKey(enemy))
        {
            GameObject aux = new GameObject("marker");
            _enemiesPosition.Add(enemy, aux);
            markers.Add(aux);
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class UFOLineRenderer : MonoBehaviour
{
    private Cat _cat;
    [SerializeField] private GameObject owner;
    [SerializeField] private LineRenderer lineRenderer;
    private float _nodeYPosition = 0.26f;

    #region Pathfinding

    private Pathfinding _pf;
    public List<Node> myPath;
    private List<Vector3> _myWaypoints;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;
    
    #endregion

    void Start()
    {
        _pf = new Pathfinding();
        transform.position = owner.transform.position;
        _cat = GameVars.Values.Cat;

        //CalculatePath(_cat.GetStartingPosition());
        //Hacer Pathfinding.
        GetThetaStar();
    }

    private void DrawLineRenderer(List<Node> waypoints) 
    {
        lineRenderer.positionCount = waypoints.Count;
        //lineRenderer.SetPosition(0, waypoints[0].transform.position);

        for (int i = 0; i < waypoints.Count; i++)
        {
            Vector3 pointPosition = new Vector3(waypoints[i].transform.position.x, _nodeYPosition, waypoints[i].transform.position.z);
            lineRenderer.SetPosition(i, pointPosition);
        }
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        startingPoint = PathfindingManager.Instance.GetClosestNode(transform.position);

        //_currentWaypoint = _enemy.GetCurrentWaypoint();
        
        endingPoint = PathfindingManager.Instance.GetClosestNode(_cat.GetStartingPosition());

        //myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);

        DrawLineRenderer(myPath);
    }
}

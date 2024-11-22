using System;
using System.Collections.Generic;
using UnityEngine;

public class UFOLineRenderer : MonoBehaviour
{
    private Cat _cat;
    private Vector3 _catPosition;
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
        //_cat.OnCatStateChange += OnRepaintLineRenderer;
        GetAStarPath();
    }

    public void OnRepaintLineRenderer(Vector3 startingPos)
    {
        _catPosition = startingPos;
        GetAStarPath();
    }

    private void DrawLineRenderer(List<Node> waypoints) 
    {
        lineRenderer.positionCount = waypoints.Count;

        for (int i = 0; i < waypoints.Count; i++)
        {
            Vector3 pointPosition = new Vector3(waypoints[i].transform.position.x, _nodeYPosition, waypoints[i].transform.position.z);
            lineRenderer.SetPosition(i, pointPosition);
        }
    }

    public void GetAStarPath()
    {
        myPath = new List<Node>();

        startingPoint = PathfindingManager.Instance.GetClosestNode(transform.position);

        var pos = (_catPosition == Vector3.zero) ? _cat.StartingPosition : _catPosition;
        endingPoint = PathfindingManager.Instance.GetClosestNode(pos);

        myPath = _pf.ConstructPathAStar(startingPoint, endingPoint);

        DrawLineRenderer(myPath);
    }
}

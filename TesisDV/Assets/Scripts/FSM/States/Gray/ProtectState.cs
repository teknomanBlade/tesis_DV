using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProtectState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;

    private bool canPathfind;
    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;
    public ProtectState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        _currentPathWaypoint = 0;
        
        _enemy.GetProtectTarget();

        //var dir = _enemy._target.transform.position - _enemy.transform.position;  Probar estos dos despues
        //_enemy.transform.forward = dir;                                           Probar estos dos despues

        GetThetaStar();
        Debug.Log("Entre a Protect");
        //_enemy.ResetPathAndSetObjective(_enemy._target.transform.position);
    }
    public void OnUpdate()
    {
        if (!_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.pursueThreshold) //Agregar Raycast para ver al player
        {
            _fsm.ChangeState(EnemyStatesEnum.ChaseState);
        }

        //float distanceToTarget = Vector3.Distance(_enemy.transform.position, _enemy._target.transform.position);
        //Les cuesta tomar el target de nuevo cuando su primer target desaparece. Por ahora funciona pero despues se podria usar el target para
        //que se muevan hacia el cuando el NavmeshPath no sea valido. Para que no se queden duros en el lugar.
        //_enemy.Move();

        _enemy._circlePos = AIManager.Instance.RequestPosition(_enemy);
        RaycastHit hit;
        Vector3 protectDir = _enemy._circlePos - _enemy.transform.position;
        Vector3 targetDir = _enemy._target.transform.position - _enemy.transform.position;
        /* if(Vector3.Distance(_enemy.transform.position, _enemy._circlePos) > 0.1f && Physics.Raycast(_enemy.transform.position, dir, out hit, dir.magnitude, GameVars.Values.GetWallLayerMask()) == true)
        {
            //_enemy.ResetPathAndSetObjective(_enemy._circlePos); //Se va el navmesh
            
            _enemy.transform.forward = dir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
        }
        else 
        {
            
        } */

        if(myPath != null && Physics.Raycast(_enemy.transform.position, targetDir, out hit, targetDir.magnitude, GameVars.Values.GetWallLayerMask()) == true)
        {
            if(myPath.Count >= 1)
            {
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                _enemy.transform.forward = dir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

                if (dir.magnitude < 0.1f)
                {
                    _currentPathWaypoint++;
                    if (_currentPathWaypoint > myPath.Count - 1)
                    {
                        Debug.Log("Nunca deberiamos llegar aca. Si estas viendo esto algo salio mal.");
                        _currentPathWaypoint = 0;
                        GetThetaStar();
                    }
                }
            }
        }
        else if((Vector3.Distance(_enemy.transform.position, _enemy._circlePos) > 0.2f))
        {
            Vector3 aux = protectDir;
            protectDir = new Vector3(aux.x, 0f, aux.z);
            _enemy.transform.forward = protectDir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
        }

        //if (distanceToTarget > _enemy.protectDistance)
        //{
            //_enemy.ResetPathAndSetObjective(_enemy._target.transform.position);
        //} 

        
        
    }
    public void OnExit()
    {
        Debug.Log("Sali de Protect");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        //startingPoint = _enemy._pfManager.GetStartNode(_enemy.transform);
        startingPoint = _enemy._pfManager.GetClosestNode(_enemy.transform.position);
        //Debug.Log("Start at " + startingPoint);

        _currentWaypoint = _enemy.GetCurrentWaypoint();
        
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._player.transform);
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._cat.transform.position);
        endingPoint = _enemy._pfManager.GetClosestNode(_enemy._target.transform.position);
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._exitPos); //el nodo final es personalizado de cada estado.
        //Debug.Log("End at " + endingPoint);
        //}

        //myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath); //esto no hace falta, es para testear.
    }
}
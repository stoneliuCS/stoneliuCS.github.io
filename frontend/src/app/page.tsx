import { Box, Divider, Paper } from '@mui/material';

const constants = {
  elevation: 5
} as const

const title = (
  <h1 className="text-center text-6xl inline-block align-middle">
    Stone Liu
  </h1>)


export default function Home() {
  return (
    <div className="w-screen h-screen">
      <div className="flex items-center justify-center w-full h-full">
        <Paper className="flex p-2 justify-center h-5/6 w-5/6" elevation={constants.elevation}>
          {title}
          <Box />
        </Paper>
      </div>
    </div>
  )
}
